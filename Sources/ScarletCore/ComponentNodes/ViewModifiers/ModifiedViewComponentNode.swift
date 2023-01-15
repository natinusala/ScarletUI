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

public struct ModifiedViewComponentInput<Content, Modifier>: ComponentInput where Content: View, Modifier: ViewModifier {
    public typealias Model = ModifiedContent<Content, Modifier>
}

public struct ModifiedViewComponentOutput<Content, Modifier>: ComponentOutput where Content: View, Modifier: ViewModifier {
    public typealias Model = ModifiedContent<Content, Modifier>

    let content: Content
    let modifier: Modifier
}

/// Component node for modified views. Contains the modifier as an edge.
/// Doesn't perform equality check on itself, however checks for equality on the modifier and content
/// to update one or the other accordingly.
public class ModifiedViewComponentNode<Content, Modifier>: ComponentNode where Content: View, Modifier: ViewModifier {
    public typealias Model = ModifiedContent<Content, Modifier>

    public var value: ModifiedContent<Content, Modifier>
    public weak var parent: (any ComponentNode)?
    public var target: Model.Target?
    public var targetCount = 0
    public var attributes = AttributesStash()

    var edge: Modifier.Node?

    init(making component: Model, in parent: (any ComponentNode)?, targetPosition: Int, using context: Context) {
        self.value = component
        self.parent = parent

        // Create the target node
        self.target = Model.makeTarget(of: component)

        // Start a first update without comparing (since we update the model with itself)
        let result = self.update(with: component, targetPosition: targetPosition, using: context, initial: true)

        // Attach the target once everything is ready
        self.insertTargetInParent(position: result.targetPosition)
    }

    public func updateEdges(from output: Model.Output?, at targetPosition: Int, using context: Context) -> UpdateResult {
        let vmcContext = ViewModifierContentContext(content: output?.content)
        let context = context.pushingVmcContext(vmcContext)

        if let edge = self.edge {
            return edge.compareAndUpdate(with: output?.modifier, targetPosition: targetPosition, using: context)
        } else if let output {
            let edge = Modifier.makeNode(of: output.modifier, in: self, targetPosition: targetPosition, using: context)
            self.edge = edge
            return UpdateResult(
                targetPosition: targetPosition,
                targetCount: edge.targetCount
            )
        } else {
            nilOutputFatalError(for: Modifier.self)
        }
    }

    public func make(component: Model) -> ModifiedViewComponentOutput<Content, Modifier> {
        let input = ModifiedViewComponentInput<Content, Modifier>()
        return Model.make(component, input: input)
    }

    public var allEdges: [(any ComponentNode)?] {
        return [
            self.edge
        ]
    }

}
