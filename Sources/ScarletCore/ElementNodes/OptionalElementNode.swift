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

public struct OptionalMakeInput<Value>: ElementInput where Value: Element {

}

public struct OptionalMakeOutput<Value, Wrapped>: ElementOutput where Value: Element, Wrapped: Element {
    let edge: Wrapped?
}

/// Node for optional elements. Doesn't perform equaliyty check on itself.
public class OptionalElementNode<Value, Wrapped>: ElementNode where Value: Element, Wrapped: Element, Value.Input == OptionalMakeInput<Value>, Value.Output == OptionalMakeOutput<Value, Wrapped> {
    public weak var parent: (any ElementNode)?
    public var target: Value.Target?
    public var targetCount = 0
    public var attributes = AttributesStash()

    /// As opposed to other nodes, having `nil` here means the node is
    /// actually missing (and not uninitialized).
    var edge: Wrapped.Node?

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

    public func make(element: Value) -> Value.Output {
        let input = OptionalMakeInput<Value>()
        return Value.make(element, input: input)
    }

    public var allEdges: [(any ElementNode)?] {
        return [
            self.edge
        ]
    }


}
