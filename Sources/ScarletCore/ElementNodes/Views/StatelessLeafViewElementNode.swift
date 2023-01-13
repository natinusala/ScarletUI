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

public struct StatelessLeafViewMakeInput<Value>: ElementInput where Value: Element {

}

public struct StatelessLeafViewMakeOutput<Value>: ElementOutput where Value: Element {

}

/// Element nodes for stateless leaf views that have no edges and no dynamic properties.
/// Performs an equality check on the element (see ``shouldUpdate(with:using:)``).
public class StatelessLeafViewElementNode<Value>: ElementNode where Value: Element, Value.Input == StatelessLeafViewMakeInput<Value>, Value.Output == StatelessLeafViewMakeOutput<Value> {
    public weak var parent: (any ElementNode)?
    public var target: Value.Target?
    public var targetCount = 0
    public var value: Value
    public var attributes = AttributesStash()
    public var context: Context
    public var targetPosition: Int

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
        // No edge to update
        return UpdateResult(
            targetPosition: targetPosition,
            targetCount: 0
        )
    }

    public func make(element: Value) -> Value.Output {
        let input = StatelessLeafViewMakeInput<Value>()
        return Value.make(element, input: input)
    }

    public var allEdges: [(any ElementNode)?] {
        return []
    }
}
