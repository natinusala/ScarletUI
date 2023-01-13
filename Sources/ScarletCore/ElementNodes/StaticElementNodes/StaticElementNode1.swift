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

// Generated by `codegen.py` from `StaticElementNode.gyb`

public struct StaticMakeInput1<Value>: ElementInput where Value: Element {

}

public struct StaticMakeOutput1<Value, E0>: ElementOutput where Value: Element, E0: Element {
    var e0: E0
}

/// An element with static edges, aka. always the same amount of edges with the same type.
/// Performs no equality check on the element so its edges will always be updated ("passthrough" element).
public class StaticElementNode1<Value, E0>: ElementNode where Value: Element, E0: Element, Value.Input == StaticMakeInput1<Value>, Value.Output == StaticMakeOutput1<Value, E0> {
    typealias Input = StaticMakeInput1<Value>
    typealias Output = StaticMakeOutput1<Value, E0>

    public weak var parent: (any ElementNode)?
    public var target: Value.Target?
    public var targetCount = 0
    public var attributes = AttributesStash()

    var e0: E0.Node?

    init(making element: Value, in parent: (any ElementNode)?, targetPosition: Int, using context: Context) {
        self.parent = parent

        // Create the target node
        self.target = Value.makeTarget(of: element)

        // Start a first update without comparing (since we update the value with itself)
        let result = self.update(with: element, targetPosition: targetPosition, using: context, initial: true)

        // Attach the target once everything is ready
        self.insertTargetInParent(position: result.targetPosition)
    }

    public func updateEdges(from output: Value.Output?, at targetPosition: Int, using context: Context) -> UpdateResult {
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

        return UpdateResult(
            targetPosition: targetPosition,
            targetCount: totalTargetCount
        )
    }

    public func make(element: Value) -> Value.Output {
        let input = Input()
        return Value.make(element, input: input)
    }

    public var allEdges: [(any ElementNode)?] {
        return [
            self.e0,
        ]
    }
}
