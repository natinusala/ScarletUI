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

public struct EnvironmentComponentInput<Model>: ComponentInput where Model: ComponentModel {

}

public struct EnvironmentComponentOutput<Model, E0>: ComponentOutput where Model: ComponentModel, E0: ComponentModel {
    var e0: E0
}

/// Component node for environment values setters.
/// Doesn't perform an equality check on itself.
public class EnvironmentComponentNode<Model, E0>: ComponentNode where Model: ComponentModel, Model: EnvironmentCollectable, E0: ComponentModel, Model.Input == EnvironmentComponentInput<Model>, Model.Output == EnvironmentComponentOutput<Model, E0> {
    typealias Input = EnvironmentComponentInput<Model>
    typealias Output = EnvironmentComponentOutput<Model, E0>

    typealias EnvironmentValue = Model.Value

    public weak var parent: (any ComponentNode)?
    public var target: Model.Target?
    public var targetCount = 0
    public var attributes = AttributesStash()

    let partialKeyPath: PartialKeyPath<EnvironmentValues>

    var e0: E0.Node?

    /// Previous known value for the environment value.
    var environmentValue: EnvironmentValue

    init(making component: Model, in parent: (any ComponentNode)?, targetPosition: Int, using context: Context) {
        // TODO: find a way to not collect twice (once here, once in `update()` below)
        let environment = Model.collectEnvironment(of: component)

        self.parent = parent
        self.environmentValue = environment.value
        self.partialKeyPath = component.partialKeyPath

        // Create the target node
        self.target = Model.makeTarget(of: component)

        // Start a first update without comparing (since we update the model with itself)
        let result = self.update(with: component, targetPosition: targetPosition, using: context, initial: true)

        // Attach the target once everything is ready
        self.insertTargetInParent(position: result.targetPosition)
    }

    public func updateEdges(from output: Model.Output?, at targetPosition: Int, using context: Context) -> UpdateResult {
        // Create edges if updating for the first time
        // Otherwise update them

        var totaltargetCount = 0

        // Edge 0
        let e0TargetPosition = targetPosition + totaltargetCount
        let e0targetCount: Int
        if let e0 = self.e0 {
            e0targetCount = e0.compareAndUpdate(
                with: output?.e0,
                targetPosition: e0TargetPosition,
                using: context
            ).targetCount
        } else if let output {
            let edge = E0.makeNode(of: output.e0, in: self, targetPosition: e0TargetPosition, using: context)
            self.e0 = edge
            e0targetCount = edge.targetCount
        } else {
            nilOutputFatalError(for: E0.self)
        }
        totaltargetCount += e0targetCount

        targetLogger.trace("\(E0.self) returned target count \(e0targetCount) - Total: \(totaltargetCount)")

        return UpdateResult(
            targetPosition: targetPosition,
            targetCount: totaltargetCount
        )
    }

    public func make(component: Model) -> Model.Output {
        let input = Input()
        return Model.make(component, input: input)
    }

    public var allEdges: [(any ComponentNode)?] {
        return [
            self.e0
        ]
    }

    public func compareEnvironment(of component: Model, using context: ComponentContext) -> (values: EnvironmentValues, changed: EnvironmentDiff) {
        // TODO: Somehow test this is called ONCE by environment change, and not once by view the environment is applied on
        let newEnvironment = Model.collectEnvironment(of: component)
        let changed = !anyEquals(lhs: self.environmentValue, rhs: newEnvironment.value)

        environmentLogger.trace("Comparing environment \(Self.self)")

        // Update state
        self.environmentValue = newEnvironment.value

        // Update store
        var values = context.environment
        values[keyPath: newEnvironment.keyPath] = newEnvironment.value

        // Set changed flag
        var changedEnvironment = context.changedEnvironment
        changedEnvironment[newEnvironment.keyPath] = changed

        return (
            values: values,
            changed: changedEnvironment
        )
    }

    public func resetEnvironmentDiff(from diff: EnvironmentDiff) -> EnvironmentDiff {
        var diff = diff
        diff[self.partialKeyPath] = false
        return diff
    }
}
