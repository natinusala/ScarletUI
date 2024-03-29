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

// Generated by `codegen.py` from `StaticComponentNode.gyb`

public struct StaticComponentInput2<Model>: ComponentInput where Model: ComponentModel {

}

public struct StaticComponentOutput2<Model, E0, E1>: ComponentOutput where Model: ComponentModel, E0: ComponentModel, E1: ComponentModel {
    var e0: E0
    var e1: E1
}

/// A component with static edges, aka. always the same amount of edges with the same type.
/// Performs no equality check on the component so its edges will always be updated ("passthrough" component).
public class StaticComponentNode2<Model, E0, E1>: ComponentNode where Model: ComponentModel, E0: ComponentModel, E1: ComponentModel, Model.Input == StaticComponentInput2<Model>, Model.Output == StaticComponentOutput2<Model, E0, E1> {
    typealias Input = StaticComponentInput2<Model>
    typealias Output = StaticComponentOutput2<Model, E0, E1>

    public weak var parent: (any ComponentNode)?
    public var target: Model.Target?
    public var targetCount = 0
    public var attributes = AttributesStash()

    var e0: E0.Node?
    var e1: E1.Node?

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
        // Create edges if updating for the first time
        // Otherwise update them

        var totalTargetCount = 0

        // Edge 0
        let e0TargetPosition = targetPosition + totalTargetCount
        let e0TargetCount: Int
        if let e0 = self.e0 {
            e0TargetCount = e0.compareAndUpdate(
                with: output?.e0,
                targetPosition: e0TargetPosition,
                using: context
            ).targetCount
        } else if let output {
            let edge = E0.makeNode(of: output.e0, in: self, targetPosition: e0TargetPosition, using: context)
            self.e0 = edge
            e0TargetCount = edge.targetCount
        } else {
            nilOutputFatalError(for: E0.self)
        }
        totalTargetCount += e0TargetCount

        targetLogger.trace("\(E0.self) returned target count \(e0TargetCount) - Total: \(totalTargetCount)")
        // Edge 1
        let e1TargetPosition = targetPosition + totalTargetCount
        let e1TargetCount: Int
        if let e1 = self.e1 {
            e1TargetCount = e1.compareAndUpdate(
                with: output?.e1,
                targetPosition: e1TargetPosition,
                using: context
            ).targetCount
        } else if let output {
            let edge = E1.makeNode(of: output.e1, in: self, targetPosition: e1TargetPosition, using: context)
            self.e1 = edge
            e1TargetCount = edge.targetCount
        } else {
            nilOutputFatalError(for: E1.self)
        }
        totalTargetCount += e1TargetCount

        targetLogger.trace("\(E1.self) returned target count \(e1TargetCount) - Total: \(totalTargetCount)")

        return UpdateResult(
            targetPosition: targetPosition,
            targetCount: totalTargetCount
        )
    }

    public func make(component: Model) -> Model.Output {
        let input = Input()
        return Model.make(component, input: input)
    }

    public var allEdges: [(any ComponentNode)?] {
        return [
            self.e0,
            self.e1,
        ]
    }
}
