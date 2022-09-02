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

public struct LeafMakeInput<Value>: MakeInput where Value: Element {

}

public struct LeafMakeOutput<Value>: MakeOutput where Value: Element {

}

/// Element nodes for leaf views that have no edges.
public class LeafElementNode<Value>: ElementNode where Value: Element, Value.Input == LeafMakeInput<Value>, Value.Output == LeafMakeOutput<Value> {
    public var parent: (any ElementNode)?
    public var implementation: Value.Implementation?
    public var cachedImplementationPosition = 0
    public var cachedImplementationCount = 0
    public var value: Value

    init(making element: Value, in parent: (any ElementNode)?, implementationPosition: Int) {
        self.value = element

        // Start a first update without comparing (since we update the value with itself)
        self.update(with: element, compare: false, implementationPosition: implementationPosition)

        // Create the implementation node
        self.implementation = Value.makeImplementation(of: element)

        // Attach the implementation once our cached values are set
        self.attachImplementationToParent()
    }

    public func updateEdges(from output: Value.Output, at implementationPosition: Int) {
        // No edge to update
    }

    public func make(element: Value) -> Value.Output {
        let input = LeafMakeInput<Value>()
        return Value.make(element, input: input)
    }
}
