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

public struct ModifiedViewMakeInput<Content, Modifier>: MakeInput where Content: View, Modifier: ViewModifier {
    public typealias Value = ModifiedContent<Content, Modifier>
}

public struct ModifiedViewMakeOutput<Content, Modifier>: MakeOutput where Content: View, Modifier: ViewModifier {
    public typealias Value = ModifiedContent<Content, Modifier>

    let content: Content
    let modifier: Modifier
}

/// Element node for modified views. Contains the modifier as an edge.
/// Doesn't perform equality check on itself, however checks for equality on the modifier and content
/// to update one or the other accordingly.
public class ModifiedViewElementNode<Content, Modifier>: ElementNode where Content: View, Modifier: ViewModifier, Modifier.Node == UserViewModifierElementNode<Modifier, Modifier.Body>, Content == Modifier.Content {
    public typealias Value = ModifiedContent<Content, Modifier>

    public var value: ModifiedContent<Content, Modifier>
    public var parent: (any ElementNode)?
    public var implementation: Never?
    public var implementationCount = 0

    var edge: Modifier.Node?

    init(making element: Value, in parent: (any ElementNode)?, implementationPosition: Int, using context: Context) {
        self.value = element

        // Start a first update without comparing (since we update the value with itself)
        let result = self.update(with: element, implementationPosition: implementationPosition, using: context)

        // Create the implementation node
        self.implementation = Value.makeImplementation(of: element)

        // Attach the implementation once everything is ready
        self.attachImplementationToParent(position: result.implementationPosition)
    }

    public func updateEdges(from output: ModifiedViewMakeOutput<Content, Modifier>, at implementationPosition: Int, using context: Context) -> UpdateResult {
        // If the modifier doesn't exist, just create it
        guard let edge else {
            let edge = Modifier.makeNode(
                of: output.modifier,
                in: self,
                implementationPosition: implementationPosition,
                using: context,
                parameters: output.content
            )
            self.edge = edge
            return UpdateResult(
                implementationPosition: implementationPosition,
                implementationCount: edge.implementationCount
            )
        }

        // If the modifier changed, call its body with the new content
        // The modifier will be responsible for checking if the content changed
        var installedModifier = output.modifier
        if edge.install(element: &installedModifier) {
            return edge.update(
                with: installedModifier,
                implementationPosition: implementationPosition,
                using: context,
                parameters: output.content
            )
        }

        // If content changed, only update the content
        guard let contentEdge = edge.edge else {
            fatalError("Tried to update uninitialized content node")
        }

        var installedContent = output.content
        if contentEdge.install(element: &installedContent) {
            return contentEdge.
        }

        // Nothing changed, don't do anything then
        return UpdateResult(
            implementationPosition: implementationPosition,
            implementationCount: self.implementationCount
        )
    }

    public func shouldUpdate(with element: ModifiedContent<Content, Modifier>) -> Bool {
        return true
    }

    public func make(element: ModifiedContent<Content, Modifier>, parameters: Any) -> ModifiedViewMakeOutput<Content, Modifier> {
        let input = ModifiedViewMakeInput<Content, Modifier>()
        return Value.make(element, input: input)
    }

    public var allEdges: [(any ElementNode)?] {
        return [
            self.edge
        ]
    }

}
