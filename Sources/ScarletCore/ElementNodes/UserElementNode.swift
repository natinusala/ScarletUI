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

public struct UserMakeInput<Value>: ElementInput where Value: Element {

}

public struct UserMakeOutput<Value, Edge>: ElementOutput where Value: Element, Edge: Element {
    let edge: Edge
}

/// Element nodes for "user" elements with a body (apps, scenes, views, view modifiers...). Always performs equality checks.
public class UserElementNode<Value, Edge>: StatefulElementNode where Value: Element, Value.Input == UserMakeInput<Value>, Value.Output == UserMakeOutput<Value, Edge>, Edge: Element {
    public var value: Value
    public weak var parent: (any ElementNode)?
    public var target: Value.Target?
    public var targetCount = 0
    public var attributes = AttributesStash()
    public var context: Context
    public var targetPosition: Int

    var edge: Edge.Node?

    init(making element: Value, in parent: (any ElementNode)?, targetPosition: Int, using context: Context) {
        self.value = element
        self.parent = parent
        self.context = context
        self.targetPosition = targetPosition

        // Set environment metadata for the type
        EnvironmentMetadataCache.shared.setCache(for: element)

        // Install the element
        var element = element
        self.install(element: &element, using: context)

        // Create the target node
        self.target = Value.makeTarget(of: element)

        // Start a first update without comparing (since we update the value with itself)
        let result = self.update(with: element, targetPosition: targetPosition, using: context, initial: true)

        // Attach the target once everything is ready
        self.insertTargetInParent(position: result.targetPosition)
    }

    public func updateEdges(from output: Value.Output?, at targetPosition: Int, using context: Context) -> UpdateResult {
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

    public func make(element: Value) -> Value.Output {
        let input = UserMakeInput<Value>()
        return Value.make(element, input: input)
    }

    public var allEdges: [(any ElementNode)?] {
        return [
            self.edge
        ]
    }
}
