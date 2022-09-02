
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

public struct StaticMakeInput3<Value>: MakeInput where Value: Element {

}

public struct StaticMakeOutput3<Value, E0, E1, E2>: MakeOutput where Value: Element, E0: Element, E1: Element, E2: Element {
    var e0: E0
    var e1: E1
    var e2: E2
}

/// An element with static edges, aka. always the same amount of edges
/// with the same type.
public class StaticElementNode3<Value, E0, E1, E2>: ElementNode where Value: Element, E0: Element, E1: Element, E2: Element, Value.Input == StaticMakeInput3<Value>, Value.Output == StaticMakeOutput3<Value, E0, E1, E2> {
    typealias Input = StaticMakeInput3<Value>
    typealias Output = StaticMakeOutput3<Value, E0, E1, E2>

    /// Node parent.
    var parent: (any ElementNode)?

    /// Value of the node.
    var value: Value

    /// Last known implementation position.
    var cachedImplementationPosition = 0

    /// Last known implementation count.
    var cachedImplementationCount = 0

    var e0: E0.Node?
    var e1: E1.Node?
    var e2: E2.Node?

    init(making element: Value) {
        self.value = element

        // Start a first update without comparing (since we update the value with itself)
        self.update(with: element, compare: false)

        // Attach the implementation once our cached values are set
        self.attachImplementationToParent()
    }

    public func update(with element: Value, compare: Bool, implementationPosition: ImplementationPosition) -> Int {
        // Compare the element to see if it changed
        // If it didn't, don't do anything
        guard !compare || !Value.equals(lhs: element, rhs: self.value) else {
            return self.cachedImplementationCount
        }

        let input = Input()
        let output = Value.make(element, input: input)

        // Override implementation position if the element is substantial since our edges
        // must start at 0 (the parent being ourself)

        self.update(element, with: output, implementationPosition: self.substantial ? 0 : implementationPosition)

        // Override implementation count if the element is substantial since it has one implementation: itself
        if self.substantial {
            self.cachedImplementationCount = 1
        }

        return self.cachedImplementationCount
    }

    func update(_ element: Value, with output: Output, implementationPosition: Int) {
        // Update value
        self.value = element

        // Create edges if updating for the first time
        // Otherwise update them

        var totalImplementationCount = 0

        // Edge 0
        let e0ImplementationPosition = implementationPosition + totalImplementationCount
        let e0ImplementationCount: Int
        if let e0 = self.e0 {
            e0ImplementationCount = e0.update(with: output.e0, compare: true, implementationPosition: e0ImplementationPosition)
        } else {
            let edge = E0.makeNode(of: output.e0, in: self, implementationPosition: e0ImplementationPosition)
            self.e0 = edge
            e0ImplementationCount = edge.cachedImplementationCount
        }
        totalImplementationCount += e0ImplementationCount
        // Edge 1
        let e1ImplementationPosition = implementationPosition + totalImplementationCount
        let e1ImplementationCount: Int
        if let e1 = self.e1 {
            e1ImplementationCount = e1.update(with: output.e1, compare: true, implementationPosition: e1ImplementationPosition)
        } else {
            let edge = E1.makeNode(of: output.e1, in: self, implementationPosition: e1ImplementationPosition)
            self.e1 = edge
            e1ImplementationCount = edge.cachedImplementationCount
        }
        totalImplementationCount += e1ImplementationCount
        // Edge 2
        let e2ImplementationPosition = implementationPosition + totalImplementationCount
        let e2ImplementationCount: Int
        if let e2 = self.e2 {
            e2ImplementationCount = e2.update(with: output.e2, compare: true, implementationPosition: e2ImplementationPosition)
        } else {
            let edge = E2.makeNode(of: output.e2, in: self, implementationPosition: e2ImplementationPosition)
            self.e2 = edge
            e2ImplementationCount = edge.cachedImplementationCount
        }
        totalImplementationCount += e2ImplementationCount

        // Update cached values
        self.cachedImplementationPosition = implementationPosition
        self.cachedImplementationCount = totalImplementationCount
    }
}
