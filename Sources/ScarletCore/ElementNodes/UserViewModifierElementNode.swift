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

public struct UserViewModifierMakeInput<Value>: MakeInput where Value: ViewModifier {
    let content: Value.Content
}

public struct UserViewModifierMakeOutput<Value, Edge>: MakeOutput where Value: ViewModifier, Edge: Element {
    let edge: Edge
}

public struct UserViewModifierParameters<Value> where Value: ViewModifier {
    enum Edge {
        /// 
        case initialized(edge: Value.Content.Node)
        case uninitialized(setter: (Value.Content.Node) -> ())
    }
    /// Content of this view modifier.
    let content: Value.Content

    let edge: Edge
}

/// Element node for user provided view modifiers. Always performs equality check.
/// The view modifier edge is the actual modified content, passed by ``ModifiedContent`` through type-erased parameters.
/// The pattern is `ModifiedContent -> ViewModifier -> ViewModifier.Body -> [...] -> ViewModifier.Content`.
public class UserViewModifierElementNode<Value, Edge>: ElementNode where Value: ViewModifier, Value.Input == UserViewModifierMakeInput<Value>, Value.Output == UserViewModifierMakeOutput<Value, Edge>, Edge: Element {
    public var value: Value
    public var parent: (any ElementNode)?
    public var implementation: Value.Implementation?
    public var implementationCount = 0

    var edge: Edge.Node?

    init(making element: Value, in parent: (any ElementNode)?, implementationPosition: Int, using context: Context, parameters: Any) {
        self.value = element

        // Start a first update without comparing (since we update the value with itself)
        let result = self.update(with: element, implementationPosition: implementationPosition, using: context, parameters: parameters)

        // Create the implementation node
        self.implementation = Value.makeImplementation(of: element)

        // Attach the implementation once everything is ready
        self.attachImplementationToParent(position: result.implementationPosition)
    }

    public func updateEdges(from output: Value.Output, at implementationPosition: Int, using context: Context) -> UpdateResult {
        if let edge = self.edge {
            return edge.installAndUpdate(with: output.edge, implementationPosition: implementationPosition, using: context)
        } else {
            let edge = Edge.makeNode(of: output.edge, in: self, implementationPosition: implementationPosition, using: context)
            self.edge = edge
            return UpdateResult(
                implementationPosition: implementationPosition,
                implementationCount: edge.implementationCount
            )
        }
    }

    public func shouldUpdate(with element: Value) -> Bool {
        // Comparison should already be made by our parent `ModifiedContent`
        return true
    }

    public func make(element: Value, parameters: Any) -> Value.Output {
        guard let parameters = parameters as? Value.Content else {
            fatalError("\(Self.self) expected parameters of type \(Value.Content.self), received \(type(of: parameters))")
        }

        let input = UserViewModifierMakeInput<Value>(content: parameters)
        return Value.make(element, input: input)
    }

    public var allEdges: [(any ElementNode)?] {
        return [
            self.edge
        ]
    }
}
