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

public struct ConditionalComponentInput<Model>: ComponentInput where Model: ComponentModel {

}

public enum ConditionalComponentOutput<Model, First, Second>: ComponentOutput where Model: ComponentModel, First: ComponentModel, Second: ComponentModel {
    case first(First)
    case second(Second)
}

/// Node for conditional components, which edge can be one type or the other depending on the path the conditional takes.
/// Does not perform equality check on itself.
public class ConditionalComponentNode<Model, First, Second>: ComponentNode where Model: ComponentModel, First: ComponentModel, Second: ComponentModel, Model.Input == ConditionalComponentInput<Model>, Model.Output == ConditionalComponentOutput<Model, First, Second> {
    public weak var parent: (any ComponentNode)?
    public var target: Model.Target?
    public var targetCount = 0
    public var attributes = AttributesStash()

    enum Edge {
        case first(First.Node)
        case second(Second.Node)

        func updateWithNil(targetPosition: Int, using context: Context) -> UpdateResult {
            switch self {
                case .first(let node):
                    return node.update(with: nil, targetPosition: targetPosition, using: context)
                case .second(let node):
                    return node.update(with: nil, targetPosition: targetPosition, using: context)
            }
        }

        func removeTargetFromParent(targetPosition: Int?) {
            switch self {
                case .first(let node):
                    node.removeTargetFromParent(targetPosition: targetPosition)
                case .second(let node):
                    node.removeTargetFromParent(targetPosition: targetPosition)
            }
        }

        var targetCount: Int {
            switch self {
                case .first(let node):
                    return node.targetCount
                case .second(let node):
                    return node.targetCount
            }
        }

        var anyNode: any ComponentNode {
            switch self {
                case .first(let node):
                    return node
                case .second(let node):
                    return node
            }
        }
    }

    var edge: Edge?

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
            return self.edge?.updateWithNil(
                targetPosition: targetPosition,
                using: context
            ) ?? UpdateResult(
                targetPosition: targetPosition,
                targetCount: self.targetCount
            )
        }

        // If we don't have an edge, create it
        guard let edge else {
            switch output {
                case .first(let first):
                    let node = First.makeNode(of: first, in: self, targetPosition: targetPosition, using: context)
                    let edge = Edge.first(node)
                    self.edge = edge
                    return UpdateResult(
                    targetPosition: targetPosition,
                    targetCount: edge.targetCount
                )
                case .second(let second):
                    let node = Second.makeNode(of: second, in: self, targetPosition: targetPosition, using: context)
                    let edge = Edge.second(node)
                    self.edge = edge
                    return UpdateResult(
                    targetPosition: targetPosition,
                    targetCount: edge.targetCount
                )
            }
        }

        // Otherwise update the edge depending on output
        switch (edge, output) {
            case (.first(let node), .first(let component)):
                // First -> First: update
                return node.update(with: component, targetPosition: targetPosition, using: context)
            case (.second(let node), .second(let component)):
                // Second -> Second: update
                return node.update(with: component, targetPosition: targetPosition, using: context)
            case (.first(let node), .second(let component)):
                // First -> Second: switch up
                node.removeTargetFromParent(targetPosition: targetPosition)

                let node = Second.makeNode(of: component, in: self, targetPosition: targetPosition, using: context)
                let edge = Edge.second(node)
                self.edge = edge
                return UpdateResult(
                targetPosition: targetPosition,
                targetCount: edge.targetCount
            )
            case (.second(let node), .first(let component)):
                // Second -> First: switch up
                node.removeTargetFromParent(targetPosition: targetPosition)

                let node = First.makeNode(of: component, in: self, targetPosition: targetPosition, using: context)
                let edge = Edge.first(node)
                self.edge = edge
                return UpdateResult(
                targetPosition: targetPosition,
                targetCount: edge.targetCount
            )
        }
    }

    public func make(component: Model) -> Model.Output {
        let input = ConditionalComponentInput<Model>()
        return Model.make(component, input: input)
    }

    public var allEdges: [(any ComponentNode)?] {
        return [
            self.edge?.anyNode
        ]
    }
}
