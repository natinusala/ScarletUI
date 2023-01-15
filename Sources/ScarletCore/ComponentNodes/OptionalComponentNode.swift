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

public struct OptionalComponentInput<Model>: ComponentInput where Model: ComponentModel {

}

public struct OptionalComponentOutput<Model, Wrapped>: ComponentOutput where Model: ComponentModel, Wrapped: ComponentModel {
    let edge: Wrapped?
}

/// Node for optional components. Doesn't perform equaliyty check on itself.
public class OptionalComponentNode<Model, Wrapped>: ComponentNode where Model: ComponentModel, Wrapped: ComponentModel, Model.Input == OptionalComponentInput<Model>, Model.Output == OptionalComponentOutput<Model, Wrapped> {
    public weak var parent: (any ComponentNode)?
    public var target: Model.Target?
    public var targetCount = 0
    public var attributes = AttributesStash()

    /// As opposed to other nodes, having `nil` here means the node is
    /// actually missing (and not uninitialized).
    var edge: Wrapped.Node?

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
        // If no output is given assume the view is unchanged
        // and update the edges if any
        guard let output else {
            return self.edge?.update(
                with: nil,
                targetPosition: targetPosition,
                using: context
            ) ?? UpdateResult(
                targetPosition: targetPosition,
                targetCount: self.targetCount
            )
        }

        switch (self.edge, output.edge) {
            case (.none, .none):
                // Edge is still missing, don't do anything
                return UpdateResult(
                    targetPosition: targetPosition,
                    targetCount: self.targetCount
                )
            case (.some(let previous), .some(let new)):
                // Edge is still present, update it
                return previous.update(
                    with: new,
                    targetPosition: targetPosition,
                    using: context
                )
            case (.none, .some(let new)):
                // Edge is new, create it
                let edge = Wrapped.makeNode(
                    of: new,
                    in: self,
                    targetPosition: targetPosition,
                    using: context
                )
                self.edge = edge
                return UpdateResult(
                    targetPosition: targetPosition,
                    targetCount: edge.targetCount
                )
            case (.some, .none):
                // Edge has been removed, destroy it
                self.edge?.removeTargetFromParent(targetPosition: targetPosition)
                self.edge = nil
                return UpdateResult(
                    targetPosition: targetPosition,
                    targetCount: 0
                )
        }
    }

    public func make(component: Model) -> Model.Output {
        let input = OptionalComponentInput<Model>()
        return Model.make(component, input: input)
    }

    public var allEdges: [(any ComponentNode)?] {
        return [
            self.edge
        ]
    }


}
