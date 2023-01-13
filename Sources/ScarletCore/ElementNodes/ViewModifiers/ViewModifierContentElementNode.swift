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

public struct ViewModifierContentMakeInput<Value>: ElementInput where Value: View {

}

public struct ViewModifierContentMakeOutput<Value>: ElementOutput where Value: View {

}

/// Element node for view modifier content placeholder. Does not perform equality check on itself.
public class ViewModifierContentElementNode<Value>: ElementNode where Value: View, Value.Input == ViewModifierContentMakeInput<Value>, Value.Output == ViewModifierContentMakeOutput<Value> {
    public weak var parent: (any ElementNode)?
    public var target: Value.Target?
    public var targetCount = 0
    public var attributes = AttributesStash()

    /// Must be type-erased since the type is dynamic from the context.
    var edge: (any ElementNode)?

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
        // Pop the context from the stack and use that to update the edge
        let (vmcContext, context) = context.poppingVmcContext()

        guard let vmcContext else {
            fatalError("Cannot update ViewModifierContent edges: context stack is empty")
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
            fatalError("Cannot create type-erased ViewModifierContent edge: content is `nil` inside the context")
        }
    }

    public func make(element: Value) -> Value.Output {
        let input = ViewModifierContentMakeInput<Value>()
        return Value.make(element, input: input)
    }

    public var allEdges: [(any ElementNode)?] {
        return [
            self.edge
        ]
    }
}
