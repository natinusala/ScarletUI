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

public struct ConditionalMakeInput<Value>: ElementInput where Value: Element {

}

public enum ConditionalMakeOutput<Value, First, Second>: ElementOutput where Value: Element, First: Element, Second: Element {
    case first(First)
    case second(Second)
}

/// Node for conditional elements, which edge can be one type or the other depending on the path the conditional takes.
/// Does not perform equality check on itself.
public class ConditionalElementNode<Value, First, Second>: ElementNode where Value: Element, First: Element, Second: Element, Value.Input == ConditionalMakeInput<Value>, Value.Output == ConditionalMakeOutput<Value, First, Second> {
    public var parent: (any ElementNode)?
    public var implementation: Value.Implementation?
    public var implementationCount = 0
    public var attributes = AttributesStash()

    enum Edge {
        case first(First.Node)
        case second(Second.Node)

        func updateWithNil(implementationPosition: Int, using context: Context) -> UpdateResult {
            switch self {
                case .first(let node):
                    return node.update(with: nil, implementationPosition: implementationPosition, using: context)
                case .second(let node):
                    return node.update(with: nil, implementationPosition: implementationPosition, using: context)
            }
        }

        func removeImplementationFromParent(implementationPosition: Int?) {
            switch self {
                case .first(let node):
                    node.removeImplementationFromParent(implementationPosition: implementationPosition)
                case .second(let node):
                    node.removeImplementationFromParent(implementationPosition: implementationPosition)
            }
        }

        var implementationCount: Int {
            switch self {
                case .first(let node):
                    return node.implementationCount
                case .second(let node):
                    return node.implementationCount
            }
        }

        var anyNode: any ElementNode {
            switch self {
                case .first(let node):
                    return node
                case .second(let node):
                    return node
            }
        }
    }

    var edge: Edge?

    init(making element: Value, in parent: (any ElementNode)?, implementationPosition: Int, using context: Context) {
        self.parent = parent

        // Create the implementation node
        self.implementation = Value.makeImplementation(of: element)

        // Start a first update without comparing (since we update the value with itself)
        let result = self.update(with: element, implementationPosition: implementationPosition, using: context)

        // Attach the implementation once everything is ready
        self.insertImplementationInParent(position: result.implementationPosition)
    }

    public func updateEdges(from output: Value.Output?, at implementationPosition: Int, using context: Context) -> UpdateResult {
        // If no output is given assume the view is unchanged
        // and update the edges if any
        guard let output else {
            return self.edge?.updateWithNil(
                implementationPosition: implementationPosition,
                using: context
            ) ?? UpdateResult(
                implementationPosition: implementationPosition,
                implementationCount: self.implementationCount
            )
        }

        // If we don't have an edge, create it
        guard let edge else {
            switch output {
                case .first(let first):
                    let node = First.makeNode(of: first, in: self, implementationPosition: implementationPosition, using: context)
                    let edge = Edge.first(node)
                    self.edge = edge
                    return UpdateResult(
                    implementationPosition: implementationPosition,
                    implementationCount: edge.implementationCount
                )
                case .second(let second):
                    let node = Second.makeNode(of: second, in: self, implementationPosition: implementationPosition, using: context)
                    let edge = Edge.second(node)
                    self.edge = edge
                    return UpdateResult(
                    implementationPosition: implementationPosition,
                    implementationCount: edge.implementationCount
                )
            }
        }

        // Otherwise update the edge depending on output
        switch (edge, output) {
            case (.first(let node), .first(let element)):
                // First -> First: update
                return node.update(with: element, implementationPosition: implementationPosition, using: context)
            case (.second(let node), .second(let element)):
                // Second -> Second: update
                return node.update(with: element, implementationPosition: implementationPosition, using: context)
            case (.first(let node), .second(let element)):
                // First -> Second: switch up
                node.removeImplementationFromParent(implementationPosition: implementationPosition)

                let node = Second.makeNode(of: element, in: self, implementationPosition: implementationPosition, using: context)
                let edge = Edge.second(node)
                self.edge = edge
                return UpdateResult(
                implementationPosition: implementationPosition,
                implementationCount: edge.implementationCount
            )
            case (.second(let node), .first(let element)):
                // Second -> First: switch up
                node.removeImplementationFromParent(implementationPosition: implementationPosition)

                let node = First.makeNode(of: element, in: self, implementationPosition: implementationPosition, using: context)
                let edge = Edge.first(node)
                self.edge = edge
                return UpdateResult(
                implementationPosition: implementationPosition,
                implementationCount: edge.implementationCount
            )
        }
    }

    public func make(element: Value) -> Value.Output {
        let input = ConditionalMakeInput<Value>()
        return Value.make(element, input: input)
    }

    public var allEdges: [(any ElementNode)?] {
        return [
            self.edge?.anyNode
        ]
    }
}
