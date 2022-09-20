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
public class ModifiedViewElementNode<Content, Modifier>: ElementNode where Content: View, Modifier: ViewModifier {
    public typealias Value = ModifiedContent<Content, Modifier>

    public var value: ModifiedContent<Content, Modifier>
    public var parent: (any ElementNode)?
    public var implementation: Value.Implementation?
    public var implementationCount = 0
    public var attributes = AttributesStash()

    var edge: Modifier.Node?

    init(making element: Value, in parent: (any ElementNode)?, implementationPosition: Int, using context: Context) {
        self.value = element
        self.parent = parent

        // Create the implementation node
        self.implementation = Value.makeImplementation(of: element)

        // Start a first update without comparing (since we update the value with itself)
        let result = self.update(with: element, implementationPosition: implementationPosition, using: context)

        // Attach the implementation once everything is ready
        self.insertImplementationInParent(position: result.implementationPosition)
    }

    public func updateEdges(from output: Value.Output?, at implementationPosition: Int, using context: Context) -> UpdateResult {
        let vmcContext = ViewModifierContentContext(content: output?.content)
        let context = context.pushingVmcContext(vmcContext)

        if let edge = self.edge {
            return edge.compareAndUpdate(with: output?.modifier, implementationPosition: implementationPosition, using: context)
        } else if let output {
            let edge = Modifier.makeNode(of: output.modifier, in: self, implementationPosition: implementationPosition, using: context)
            self.edge = edge
            return UpdateResult(
                implementationPosition: implementationPosition,
                implementationCount: edge.implementationCount
            )
        } else {
            nilOutputFatalError(for: Modifier.self)
        }
    }

    public func make(element: Value) -> ModifiedViewMakeOutput<Content, Modifier> {
        let input = ModifiedViewMakeInput<Content, Modifier>()
        return Value.make(element, input: input)
    }

    public var allEdges: [(any ElementNode)?] {
        return [
            self.edge
        ]
    }

}
