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

public struct LeafViewMakeInput<Value>: ElementInput where Value: Element {

}

public struct LeafViewMakeOutput<Value>: ElementOutput where Value: Element {

}

/// Element nodes for leaf views that have no edges.
/// Performs an equality check on the element (see ``shouldUpdate(with:using:)``).
public class LeafViewElementNode<Value>: StatefulElementNode where Value: Element, Value.Input == LeafViewMakeInput<Value>, Value.Output == LeafViewMakeOutput<Value> {
    public var parent: (any ElementNode)?
    public var implementation: Value.Implementation?
    public var implementationCount = 0
    public var value: Value
    public var attributes = AttributesStash()
    public var context: Context
    public var implementationPosition: Int

    init(making element: Value, in parent: (any ElementNode)?, implementationPosition: Int, using context: Context) {
        self.value = element
        self.parent = parent
        self.context = context
        self.implementationPosition = implementationPosition

        // Set environment metadata for the type
        EnvironmentMetadataCache.shared.setCache(for: element)

        // Install the element
        var element = element
        self.install(element: &element, using: context)

        // Create the implementation node
        self.implementation = Value.makeImplementation(of: element)

        // Start a first update without comparing (since we update the value with itself)
        let result = self.update(with: element, implementationPosition: implementationPosition, using: context, initial: true)

        // Attach the implementation once everything is ready
        self.insertImplementationInParent(position: result.implementationPosition)
    }

    public func updateEdges(from output: Value.Output?, at implementationPosition: Int, using context: Context) -> UpdateResult {
        // No edge to update
        return UpdateResult(
            implementationPosition: implementationPosition,
            implementationCount: 0
        )
    }

    public func make(element: Value) -> Value.Output {
        let input = LeafViewMakeInput<Value>()
        return Value.make(element, input: input)
    }

    public var allEdges: [(any ElementNode)?] {
        return []
    }
}
