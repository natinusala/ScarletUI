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

public struct OptionalMakeInput<Value>: MakeInput where Value: Element {

}

public struct OptionalMakeOutput<Value, Wrapped>: MakeOutput where Value: Element, Wrapped: Element {
    let edge: Wrapped?
}

/// Node for optional elements. Doesn't perform equaliyty check on itself.
public class OptionalElementNode<Value, Wrapped>: ElementNode where Value: Element, Wrapped: Element, Value.Input == OptionalMakeInput<Value>, Value.Output == OptionalMakeOutput<Value, Wrapped> {
    public var value: Value
    public var parent: (any ElementNode)?
    public var implementation: Value.Implementation?
    public var implementationCount = 0

    /// As opposed to other nodes, having `nil` here means the node is
    /// actually missing (and not uninitialized).
    var edge: Wrapped.Node?

    init(making element: Value, in parent: (any ElementNode)?, implementationPosition: Int, using context: Context) {
        self.value = element
        self.parent = parent

        // Create the implementation node
        self.implementation = Value.makeImplementation(of: element)

        // Start a first update without comparing (since we update the value with itself)
        let result = self.update(with: element, implementationPosition: implementationPosition, using: context)

        // Attach the implementation once everything is ready
        self.attachImplementationToParent(position: result.implementationPosition)
    }

    public func updateEdges(from output: Value.Output?, at implementationPosition: Int, using context: Context) -> UpdateResult {
        // If no output is given assume the view is unchanged
        // and update the edges if any
        guard let output else {
            return self.edge?.update(
                with: nil,
                implementationPosition: implementationPosition,
                using: context
            ) ?? UpdateResult(
                implementationPosition: implementationPosition,
                implementationCount: self.implementationCount
            )
        }

        switch (self.edge, output.edge) {
            case (.none, .none):
                // Edge is still missing, don't do anything
                return UpdateResult(
                    implementationPosition: implementationPosition,
                    implementationCount: self.implementationCount
                )
            case (.some(let previous), .some(let new)):
                // Edge is still present, update it
                return previous.update(
                    with: new,
                    implementationPosition: implementationPosition,
                    using: context
                )
            case (.none, .some(let new)):
                // Edge is new, create it
                let edge = Wrapped.makeNode(
                    of: new,
                    in: self,
                    implementationPosition: implementationPosition,
                    using: context
                )
                self.edge = edge
                return UpdateResult(
                    implementationPosition: implementationPosition,
                    implementationCount: edge.implementationCount
                )
            case (.some(let previous), .none):
                // Edge has been removed, destroy it
                fatalError("Unimplemented")
        }
    }

    public func shouldUpdate(with element: Value) -> Bool {
        return true
    }

    public func make(element: Value) -> Value.Output {
        let input = OptionalMakeInput<Value>()
        return Value.make(element, input: input)
    }

    public var allEdges: [(any ElementNode)?] {
        return [
            self.edge
        ]
    }


}