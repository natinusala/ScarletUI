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

public struct UserMakeInput<Value>: MakeInput where Value: Element {

}

public struct UserMakeOutput<Value, Edge>: MakeOutput where Value: Element, Edge: Element {
    let edge: Edge
}

/// Element nodes for "user" elements (apps, scenes, views, view modifiers...). Always performs equality checks.
public class UserElementNode<Value, Edge>: ElementNode where Value: Element, Value.Input == UserMakeInput<Value>, Value.Output == UserMakeOutput<Value, Edge>, Edge: Element {
    public var value: Value
    public var parent: (any ElementNode)?
    public var implementation: Value.Implementation?
    public var implementationCount = 0

    var edge: Edge.Node?

    init(making element: Value, in parent: (any ElementNode)?, implementationPosition: Int) {
        self.value = element

        // Start a first update without comparing (since we update the value with itself)
        let result = self.update(with: element, implementationPosition: implementationPosition, forced: true)

        // Create the implementation node
        self.implementation = Value.makeImplementation(of: element)

        // Attach the implementation once everything is ready
        self.attachImplementationToParent(position: result.implementationPosition)
    }

    public func updateEdges(from output: Value.Output, at implementationPosition: Int) -> UpdateResult {
        if let edge = self.edge {
            return edge.update(with: output.edge, implementationPosition: implementationPosition)
        } else {
            let edge = Edge.makeNode(of: output.edge, in: self, implementationPosition: implementationPosition)
            self.edge = edge
            return UpdateResult(
                implementationPosition: implementationPosition,
                implementationCount: edge.implementationCount
            )
        }
    }

    public func make(element: Value) -> Value.Output {
        let input = UserMakeInput<Value>()
        return Value.make(element, input: input)
    }

    public func shouldUpdate(with element: Value) -> Bool {
        return !anyEquals(lhs: self.value, rhs: element)
    }
}
