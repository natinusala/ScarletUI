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

public struct LeafViewMakeInput<Value>: MakeInput where Value: Element {

}

public struct LeafViewMakeOutput<Value>: MakeOutput where Value: Element {

}

/// Element nodes for leaf views that have no edges.
/// Performs an equality check on the element (see ``shouldUpdate(with:)``).
public class LeafViewElementNode<Value>: ElementNode where Value: Element, Value.Input == LeafViewMakeInput<Value>, Value.Output == LeafViewMakeOutput<Value> {
    public var parent: (any ElementNode)?
    public var implementation: Value.Implementation?
    public var implementationCount = 0
    public var value: Value

    init(making element: Value, in parent: (any ElementNode)?, implementationPosition: Int, using context: Context) {
        self.value = element

        // Start a first update without comparing (since we update the value with itself)
        let result = self.update(with: element, implementationPosition: implementationPosition, using: context)

        // Create the implementation node
        self.implementation = Value.makeImplementation(of: element)

        // Attach the implementation once everything is ready
        self.attachImplementationToParent(position: result.implementationPosition)
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

    public func shouldUpdate(with element: Value) -> Bool {
        // Even if leaves are mostly built-ins elements with only attributes,
        // it doesn't cost much to make the check anyway for user elements
        // since updating leaves is cheap (they have no edges) and they usually contain few properties
        return anyEquals(lhs: self.value, rhs: element)
    }

    public var allEdges: [(any ElementNode)?] {
        return []
    }
}
