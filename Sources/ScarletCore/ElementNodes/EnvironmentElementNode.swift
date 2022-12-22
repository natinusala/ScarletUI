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

public struct EnvironmentMakeInput<Value>: ElementInput where Value: Element {

}

public struct EnvironmentMakeOutput<Value, E0>: ElementOutput where Value: Element, E0: Element {
    var e0: E0
}

/// Element node for environment values setters.
/// Doesn't perform an equality check on itself.
public class EnvironmentElementNode<Value, E0>: ElementNode where Value: Element, Value: EnvironmentCollectable, E0: Element, Value.Input == EnvironmentMakeInput<Value>, Value.Output == EnvironmentMakeOutput<Value, E0> {
    typealias Input = EnvironmentMakeInput<Value>
    typealias Output = EnvironmentMakeOutput<Value, E0>

    typealias EnvironmentValue = Value.Value

    public var parent: (any ElementNode)?
    public var implementation: Value.Implementation?
    public var implementationCount = 0
    public var attributes = AttributesStash()

    var e0: E0.Node?

    /// Previous known value for the environment value.
    var environmentValue: EnvironmentValue

    init(making element: Value, in parent: (any ElementNode)?, implementationPosition: Int, using context: Context) {
        let environment = Value.collectEnvironment(of: element)

        self.parent = parent
        self.environmentValue = environment.value

        // Create the implementation node
        self.implementation = Value.makeImplementation(of: element)

        // Start a first update without comparing (since we update the value with itself)
        let result = self.update(with: element, implementationPosition: implementationPosition, using: context)

        // Attach the implementation once everything is ready
        self.insertImplementationInParent(position: result.implementationPosition)
    }

    public func updateEdges(from output: Value.Output?, at implementationPosition: Int, using context: Context) -> UpdateResult {
        // Create edges if updating for the first time
        // Otherwise update them

        var totalImplementationCount = 0

        // Edge 0
        let e0ImplementationPosition = implementationPosition + totalImplementationCount
        let e0ImplementationCount: Int
        if let e0 = self.e0 {
            e0ImplementationCount = e0.compareAndUpdate(
                with: output?.e0,
                implementationPosition: e0ImplementationPosition,
                using: context
            ).implementationCount
        } else if let output {
            let edge = E0.makeNode(of: output.e0, in: self, implementationPosition: e0ImplementationPosition, using: context)
            self.e0 = edge
            e0ImplementationCount = edge.implementationCount
        } else {
            nilOutputFatalError(for: E0.self)
        }
        totalImplementationCount += e0ImplementationCount

        implementationLogger.trace("\(E0.self) returned implementation count \(e0ImplementationCount) - Total: \(totalImplementationCount)")

        return UpdateResult(
            implementationPosition: implementationPosition,
            implementationCount: totalImplementationCount
        )
    }

    public func make(element: Value) -> Value.Output {
        let input = Input()
        return Value.make(element, input: input)
    }

    public var allEdges: [(any ElementNode)?] {
        return [
            self.e0
        ]
    }

    public func compareEnvironment(of element: Value, using context: ElementNodeContext) -> (values: EnvironmentValues, changed: EnvironmentDiff) {
        let newEnvironment = Value.collectEnvironment(of: element)
        let changed = !elementEquals(lhs: self.environmentValue, rhs: newEnvironment.value)

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
}
