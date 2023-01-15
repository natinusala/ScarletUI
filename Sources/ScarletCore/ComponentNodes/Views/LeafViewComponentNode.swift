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

public struct LeafViewComponentInput<Model>: ComponentInput where Model: ComponentModel {

}

public struct LeafViewComponentOutput<Model>: ComponentOutput where Model: ComponentModel {

}

/// Component nodes for leaf views that have no edges.
/// Performs an equality check on the component (see ``shouldUpdate(with:using:)``).
public class LeafViewComponentNode<Model>: StatefulComponentNode where Model: ComponentModel, Model.Input == LeafViewComponentInput<Model>, Model.Output == LeafViewComponentOutput<Model> {
    public weak var parent: (any ComponentNode)?
    public var target: Model.Target?
    public var targetCount = 0
    public var model: Model
    public var attributes = AttributesStash()
    public var context: Context
    public var targetPosition: Int

    init(making component: Model, in parent: (any ComponentNode)?, targetPosition: Int, using context: Context) {
        self.model = component
        self.parent = parent
        self.context = context
        self.targetPosition = targetPosition

        // Set environment metadata for the type
        EnvironmentMetadataCache.shared.setCache(for: component)

        // Install the component
        var component = component
        self.install(component: &component, using: context)

        // Create the target node
        self.target = Model.makeTarget(of: component)

        // Start a first update without comparing (since we update the model with itself)
        let result = self.update(with: component, targetPosition: targetPosition, using: context, initial: true)

        // Attach the target once everything is ready
        self.insertTargetInParent(position: result.targetPosition)
    }

    public func updateEdges(from output: Model.Output?, at targetPosition: Int, using context: Context) -> UpdateResult {
        // No edge to update
        return UpdateResult(
            targetPosition: targetPosition,
            targetCount: 0
        )
    }

    public func make(component: Model) -> Model.Output {
        let input = LeafViewComponentInput<Model>()
        return Model.make(component, input: input)
    }

    public var allEdges: [(any ComponentNode)?] {
        return []
    }
}
