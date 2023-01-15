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

public struct StatelessLeafSceneComponentInput<Model>: ComponentInput where Model: ComponentModel {

}

public struct StatelessLeafSceneComponentOutput<Model, Edge>: ComponentOutput where Model: ComponentModel, Edge: ComponentModel {
    let edge: Edge
}

/// Component nodes for scenes that have a view as content and no dynamic properties. Does not perform equality check.
public class StatelessLeafSceneComponentNode<Model, Edge>: ComponentNode where Model: ComponentModel, Model.Input == StatelessLeafSceneComponentInput<Model>, Model.Output == StatelessLeafSceneComponentOutput<Model, Edge>, Edge: ComponentModel {
    public weak var parent: (any ComponentNode)?
    public var target: Model.Target?
    public var targetCount = 0
    public var attributes = AttributesStash()

    var edge: Edge.Node?

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
        if let edge = self.edge {
            return edge.compareAndUpdate(with: output?.edge, targetPosition: targetPosition, using: context)
        } else if let output {
            let edge = Edge.makeNode(of: output.edge, in: self, targetPosition: targetPosition, using: context)
            self.edge = edge
            return UpdateResult(
                targetPosition: targetPosition,
                targetCount: edge.targetCount
            )
        } else {
            nilOutputFatalError(for: Edge.self)
        }
    }

    public func make(component: Model) -> Model.Output {
        let input = StatelessLeafSceneComponentInput<Model>()
        return Model.make(component, input: input)
    }

    public var allEdges: [(any ComponentNode)?] {
        return [
            self.edge
        ]
    }
}
