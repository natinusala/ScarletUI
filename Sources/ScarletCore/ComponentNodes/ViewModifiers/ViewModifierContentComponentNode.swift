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

public struct ViewModifierContentComponentInput<Model>: ComponentInput where Model: View {

}

public struct ViewModifierContentComponentOutput<Model>: ComponentOutput where Model: View {

}

/// Component node for view modifier content placeholder. Does not perform equality check on itself.
public class ViewModifierContentComponentNode<Model>: ComponentNode where Model: View, Model.Input == ViewModifierContentComponentInput<Model>, Model.Output == ViewModifierContentComponentOutput<Model> {
    public weak var parent: (any ComponentNode)?
    public var target: Model.Target?
    public var targetCount = 0
    public var attributes = AttributesStash()

    /// Must be type-erased since the type is dynamic from the context.
    var edge: (any ComponentNode)?

    init(making component: Model, in parent: (any ComponentNode)?, targetPosition: Int, using context: Context) {
        self.parent = parent

        // Create the target node
        self.target = Model.makeTarget(of: component)

        // Start a first update without comparing (since we update the model with itself)
        let result = self.update(with: component, targetPosition: targetPosition, using: context, initial: true)

        // Attach the target once everything is ready
        self.insertTargetInParent(position: result.targetPosition)
    }

    public func updateEdges(from output: Model.Output?, at targetPosition: Int, using context: Context) -> UpdateResult {
        // Pop the context from the stack and use that to update the edge
        let (vmcContext, context) = context.poppingVmcContext()

        guard let vmcContext else {
            fatalError("Cannot update 'ViewModifierContent' edges: context stack is empty")
        }

        if let edge = self.edge {
            return edge.compareAndUpdateAny(with: vmcContext.content, targetPosition: targetPosition, using: context)
        } else if let content = vmcContext.content {
            let edge = content.makeAnyNode(in: self, targetPosition: targetPosition, using: context)
            self.edge = edge
            return UpdateResult(
                targetPosition: targetPosition,
                targetCount: edge.targetCount
            )
        } else {
            fatalError("Cannot create type-erased 'ViewModifierContent' edge: content is `nil` inside the context")
        }
    }

    public func make(component: Model) -> Model.Output {
        let input = ViewModifierContentComponentInput<Model>()
        return Model.make(component, input: input)
    }

    public var allEdges: [(any ComponentNode)?] {
        return [
            self.edge
        ]
    }
}
