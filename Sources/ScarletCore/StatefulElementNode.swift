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

/// A node for "stateful" elements. Stateful elements are elements that:
/// - may have dynamic properties
/// - need to be compared before updating (equality check)
///
/// Stateful element nodes store their element for that purpose.
/// Only stateful elements are installed.
///
/// All user elements are stateful.
public protocol StatefulElementNode: ElementNode {
    /// Value for the element.
    var value: Value { get set }

    /// Last context used to update the element.
    /// Used to update it again if a dynamic property changes.
    var context: Context { get set }

    /// Last implementation position used to update the element.
    /// Used to update it again if a dynamic property changes.
    var implementationPosition: Int { get set }
}

public extension StatefulElementNode {
    /// Default implementation for stored element nodes: compare the stored value
    /// with the new one.
    func shouldUpdate(with element: Value, using context: ElementNodeContext) -> Bool {
        return !elementEquals(lhs: self.value, rhs: element)
    }

    func storeValue(_ value: Value) {
        self.value = value
    }

    func storeContext(_ context: Context) {
        self.context = context
    }

    func storeImplementationPosition(_ position: Int) {
        self.implementationPosition = position
    }

    var valueDebugDescription: String {
        return self.value.debugDescription
    }

    func compareAndUpdate(with element: Value?, implementationPosition: Int, using context: Context) -> UpdateResult {
        // If no value is given, assume its direct input didn't change
        guard let element else {
            // If any element variable changed, take our own stored view, install it with the new environment values
            // and update with that
            if EnvironmentMetadataCache.shared.shouldUpdate(element: Value.self, using: context.changedEnvironment) {
                var installed = self.value
                self.install(element: &installed, using: context)

                return self.update(with: installed, implementationPosition: implementationPosition, using: context)
            }

            // Otherwise assume the view is unchanged so perform an update giving `nil` as element
            return self.update(with: nil, implementationPosition: implementationPosition, using: context)
        }

        // If any state variable changed, always install and update the view since
        // we know it's outdated
        if context.hasStateChanged {
            var installed = element
            self.install(element: &installed, using: context)

            return self.update(with: installed, implementationPosition: implementationPosition, using: context)
        }

        // If an environment variable that we use changed, also update the view
        if EnvironmentMetadataCache.shared.shouldUpdate(element: Value.self, using: context.changedEnvironment) {
            var installed = element
            self.install(element: &installed, using: context)

            return self.update(with: installed, implementationPosition: implementationPosition, using: context)
        }

        // Then compare fields ignoring dynamic variables
        if self.shouldUpdate(with: element, using: context) {
            var installed = element
            self.install(element: &installed, using: context)

            return self.update(with: installed, implementationPosition: implementationPosition, using: context)
        }

        // TODO: check if we are inside a ViewModifier - if not, there is no point to continue here.
        //       Instead, continue by checking if any subsequent node has different context
        //       and restart the update there

        // Otherwise give `nil` if the element is equal to the previous one
        // since some distant edges may change depending on context
        return self.update(with: nil, implementationPosition: implementationPosition, using: context)
    }

    func install(element: inout Value, using context: ElementNodeContext) {
        // Iterate over all properties and accept the visitor into each dynamic one
        do {
            let visitor = DynamicPropertiesInstaller(node: self)

            let info = try cachedTypeInfo(of: Value.self)

            for property in info.properties {
                let current = try property.get(from: self.value)

                switch current {
                    case let currentState as DynamicProperty:
                        try currentState.accept(
                            visitor: visitor,
                            in: property,
                            target: &element,
                            using: context
                        )
                    default:
                        break
                }
            }
        } catch {
            fatalError("Error while visiting dynamic properties: \(error)")
        }
    }

    /// Called when a state property has a value change.
    func notifyStateChange() {
        // Take the stored value and make it again as it is
        // Set context state change
        let context = self.context.settingStateChange()
        _ = self.update(with: self.value, implementationPosition: self.implementationPosition, using: context)
    }
}

/// Visitor used to install dynamic properties on elements.
private class DynamicPropertiesInstaller<Visited: Element, Node: StatefulElementNode>: DynamicPropertiesVisitor where Node.Value == Visited {
    let node: Node

    init(node: Node) {
        self.node = node
    }

    func visitStateProperty<Value>(_ property: PropertyInfo, current: State<Value>, target: inout Visited, type: Value.Type) throws {
        // Take the existing state property, setup a new location if needed and set the new location
        // in the target element
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
            fatalError("Expected to find environment value with type Environment<\(Value.self)>")
        }

        // If the value changed, set the new value
        // Otherwise just copy over the previous environment we had
        if previousValue.changed(using: diff) {
            current.setValue(from: values)
        }

        try property.set(value: current, on: &target)
    }
}
