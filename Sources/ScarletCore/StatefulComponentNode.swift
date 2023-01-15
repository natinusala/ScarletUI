/*
   Copyright 2022 natinusala

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
*/

import Runtime

/// A node for "stateful" components. Stateful components are components that:
/// - may have dynamic properties
/// - need to be compared before updating (equality check)
///
/// Stateful component nodes store their model for that purpose.
/// Only stateful components are installed.
///
/// All composable user components are stateful.
public protocol StatefulComponentNode: ComponentNode {
    /// Current model of the component.
    var model: Model { get set }

    /// Last context used to update the component.
    /// Used to update it again if a dynamic property changes.
    var context: Context { get set }

    /// Last target position used to update the component.
    /// Used to update it again if a dynamic property changes.
    var targetPosition: Int { get set }
}

public extension StatefulComponentNode {
    /// Default target for stored component nodes: compare the stored model
    /// with the new one.
    func shouldUpdate(with component: Model, using context: ComponentContext) -> Bool {
        // If the view is a container, don't check it since it's redundant
        // with checking its content
        if let _ = component as? any ContainerView {
            return true
        }

        return !anyEquals(lhs: self.model, rhs: component)
    }

    func storeModel(_ model: Model) {
        self.model = model
    }

    func storeContext(_ context: Context) {
        self.context = context
    }

    func storeTargetPosition(_ position: Int) {
        self.targetPosition = position
    }

    var modelDebugDescription: String {
        return self.model.debugDescription
    }

    func compareAndUpdate(with component: Model?, targetPosition: Int, using context: Context) -> UpdateResult {
        // If no model is given, assume its direct input didn't change
        guard let component else {
            // If any component variable changed, take our own stored view, install it with the new environment values
            // and update with that
            if EnvironmentMetadataCache.shared.shouldUpdate(component: Model.self, using: context.changedEnvironment) {
                var installed = self.model
                self.install(component: &installed, using: context)

                return self.update(with: installed, targetPosition: targetPosition, using: context)
            }

            // Otherwise assume the view is unchanged so perform an update giving `nil` as component
            return self.update(with: nil, targetPosition: targetPosition, using: context)
        }

        // If any state variable changed, always install and update the view since
        // we know it's outdated
        if context.hasStateChanged {
            var installed = component
            self.install(component: &installed, using: context)

            return self.update(with: installed, targetPosition: targetPosition, using: context)
        }

        // If an environment variable that we use changed, also update the view
        if EnvironmentMetadataCache.shared.shouldUpdate(component: Model.self, using: context.changedEnvironment) {
            var installed = component
            self.install(component: &installed, using: context)

            return self.update(with: installed, targetPosition: targetPosition, using: context)
        }

        // Then compare fields ignoring dynamic variables
        if self.shouldUpdate(with: component, using: context) {
            var installed = component
            self.install(component: &installed, using: context)

            return self.update(with: installed, targetPosition: targetPosition, using: context)
        }

        // TODO: check if we are inside a ViewModifier - if not, there is no point to continue here.
        //       Instead, continue by checking if any subsequent node has different context
        //       and restart the update there

        // Otherwise give `nil` if the component is equal to the previous one
        // since some distant edges may change depending on context
        return self.update(with: nil, targetPosition: targetPosition, using: context)
    }

    func install(component: inout Model, using context: ComponentContext) {
        // Iterate over all properties and accept the visitor into each dynamic one
        fatalAttempt(to: "visit dynamic properties of '\(Model.self)'") {
            let visitor = DynamicPropertiesInstaller(node: self)
            try visitor.walk(self.model, target: &component, using: context)
        }
    }

    /// Called when a state property has a value change.
    func notifyStateChange() {
        // Take the stored model and "make" it again as it is
        // Set context state change
        benchmark("'\(Model.self)' state update") {
            let context = self.context.settingStateChange()
            _ = self.update(with: self.model, targetPosition: self.targetPosition, using: context)
        }
    }
}

/// Visitor used to install dynamic properties on components.
private class DynamicPropertiesInstaller<Visited: ComponentModel, Node: StatefulComponentNode>: _DynamicPropertiesVisitor where Node.Model == Visited {
    let node: Node

    init(node: Node) {
        self.node = node
    }

    func visitStateProperty<Value>(_ property: PropertyInfo, current: State<Value>, target: inout Visited, type: Value.Type) throws {
        // Take the existing state property, setup a new location if needed and set the new location
        // in the target model
        if current.location == nil {
            stateLogger.trace("State location not found, making a new one")

            let location = StateLocation(value: current.defaultValue, node: self.node)
            try property.set(value: current.withLocation(location), on: &target)
        } else {
            stateLogger.trace("Using existing state location")
            try property.set(value: current, on: &target)
        }
    }

    func visitEnvironmentProperty<Value>(
        _ property: PropertyInfo,
        current: Environment<Value>,
        target: inout Visited,
        type: Value.Type,
        values: EnvironmentValues,
        diff: EnvironmentDiff
    ) throws {
        // If the environment property is not installed, set the initial value and install it
        if current.location == nil {
            stateLogger.trace("Environment location not found, making a new one")
            let location = EnvironmentLocation(keyPath: current.keyPath, value: values[keyPath: current.keyPath])
            try property.set(value: current.withLocation(location), on: &target)
            return
        }

        stateLogger.trace("Using existing environment location")

        // Previously installed value
        guard let previousValue = try property.get(from: target) as? Environment<Value> else {
            fatalError("Expected to find environment value with type 'Environment<\(Value.self)>'")
        }

        // If the value changed, set the new value
        // Otherwise just copy over the previous environment we had
        if previousValue.changed(using: diff) {
            current.setValue(from: values)
        }

        try property.set(value: current, on: &target)
    }
}
