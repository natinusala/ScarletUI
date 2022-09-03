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

public struct StaticMakeInput8<Value>: MakeInput where Value: Element {

}

public struct StaticMakeOutput8<Value, E0, E1, E2, E3, E4, E5, E6, E7>: MakeOutput where Value: Element, E0: Element, E1: Element, E2: Element, E3: Element, E4: Element, E5: Element, E6: Element, E7: Element {
    var e0: E0
    var e1: E1
    var e2: E2
    var e3: E3
    var e4: E4
    var e5: E5
    var e6: E6
    var e7: E7
}

/// An element with static edges, aka. always the same amount of edges with the same type.
/// Performs no equality check on the element so its edges will always be updated ("passthrough" element).
public class StaticElementNode8<Value, E0, E1, E2, E3, E4, E5, E6, E7>: ElementNode where Value: Element, E0: Element, E1: Element, E2: Element, E3: Element, E4: Element, E5: Element, E6: Element, E7: Element, Value.Input == StaticMakeInput8<Value>, Value.Output == StaticMakeOutput8<Value, E0, E1, E2, E3, E4, E5, E6, E7> {
    typealias Input = StaticMakeInput8<Value>
    typealias Output = StaticMakeOutput8<Value, E0, E1, E2, E3, E4, E5, E6, E7>

    public var value: Value
    public var parent: (any ElementNode)?
    public var implementation: Value.Implementation?
    public var implementationCount = 0

    var e0: E0.Node?
    var e1: E1.Node?
    var e2: E2.Node?
    var e3: E3.Node?
    var e4: E4.Node?
    var e5: E5.Node?
    var e6: E6.Node?
    var e7: E7.Node?

    init(making element: Value, in parent: (any ElementNode)?, implementationPosition: Int) {
        self.value = element

        // Start a first update without comparing (since we update the value with itself)
        let result = self.update(with: element, implementationPosition: implementationPosition, forced: true)

        // Create the implementation node
        self.implementation = Value.makeImplementation(of: element)

        // Attach the implementation once everything is ready
        self.attachImplementationToParent(position: result.implementationPosition)
    }

    public func updateEdges(from output: Value.Output, at implementationPosition: Int) -> UpdateResult {
        // Create edges if updating for the first time
        // Otherwise update them

        var totalImplementationCount = 0

        // Edge 0
        let e0ImplementationPosition = implementationPosition + totalImplementationCount
        let e0ImplementationCount: Int
        if let e0 = self.e0 {
            e0ImplementationCount = e0.update(with: output.e0, implementationPosition: e0ImplementationPosition).implementationCount
        } else {
            let edge = E0.makeNode(of: output.e0, in: self, implementationPosition: e0ImplementationPosition)
            self.e0 = edge
            e0ImplementationCount = edge.implementationCount
        }
        totalImplementationCount += e0ImplementationCount

        // Edge 1
        let e1ImplementationPosition = implementationPosition + totalImplementationCount
        let e1ImplementationCount: Int
        if let e1 = self.e1 {
            e1ImplementationCount = e1.update(with: output.e1, implementationPosition: e1ImplementationPosition).implementationCount
        } else {
            let edge = E1.makeNode(of: output.e1, in: self, implementationPosition: e1ImplementationPosition)
            self.e1 = edge
            e1ImplementationCount = edge.implementationCount
        }
        totalImplementationCount += e1ImplementationCount

        // Edge 2
        let e2ImplementationPosition = implementationPosition + totalImplementationCount
        let e2ImplementationCount: Int
        if let e2 = self.e2 {
            e2ImplementationCount = e2.update(with: output.e2, implementationPosition: e2ImplementationPosition).implementationCount
        } else {
            let edge = E2.makeNode(of: output.e2, in: self, implementationPosition: e2ImplementationPosition)
            self.e2 = edge
            e2ImplementationCount = edge.implementationCount
        }
        totalImplementationCount += e2ImplementationCount

        // Edge 3
        let e3ImplementationPosition = implementationPosition + totalImplementationCount
        let e3ImplementationCount: Int
        if let e3 = self.e3 {
            e3ImplementationCount = e3.update(with: output.e3, implementationPosition: e3ImplementationPosition).implementationCount
        } else {
            let edge = E3.makeNode(of: output.e3, in: self, implementationPosition: e3ImplementationPosition)
            self.e3 = edge
            e3ImplementationCount = edge.implementationCount
        }
        totalImplementationCount += e3ImplementationCount

        // Edge 4
        let e4ImplementationPosition = implementationPosition + totalImplementationCount
        let e4ImplementationCount: Int
        if let e4 = self.e4 {
            e4ImplementationCount = e4.update(with: output.e4, implementationPosition: e4ImplementationPosition).implementationCount
        } else {
            let edge = E4.makeNode(of: output.e4, in: self, implementationPosition: e4ImplementationPosition)
            self.e4 = edge
            e4ImplementationCount = edge.implementationCount
        }
        totalImplementationCount += e4ImplementationCount

        // Edge 5
        let e5ImplementationPosition = implementationPosition + totalImplementationCount
        let e5ImplementationCount: Int
        if let e5 = self.e5 {
            e5ImplementationCount = e5.update(with: output.e5, implementationPosition: e5ImplementationPosition).implementationCount
        } else {
            let edge = E5.makeNode(of: output.e5, in: self, implementationPosition: e5ImplementationPosition)
            self.e5 = edge
            e5ImplementationCount = edge.implementationCount
        }
        totalImplementationCount += e5ImplementationCount

        // Edge 6
        let e6ImplementationPosition = implementationPosition + totalImplementationCount
        let e6ImplementationCount: Int
        if let e6 = self.e6 {
            e6ImplementationCount = e6.update(with: output.e6, implementationPosition: e6ImplementationPosition).implementationCount
        } else {
            let edge = E6.makeNode(of: output.e6, in: self, implementationPosition: e6ImplementationPosition)
            self.e6 = edge
            e6ImplementationCount = edge.implementationCount
        }
        totalImplementationCount += e6ImplementationCount

        // Edge 7
        let e7ImplementationPosition = implementationPosition + totalImplementationCount
        let e7ImplementationCount: Int
        if let e7 = self.e7 {
            e7ImplementationCount = e7.update(with: output.e7, implementationPosition: e7ImplementationPosition).implementationCount
        } else {
            let edge = E7.makeNode(of: output.e7, in: self, implementationPosition: e7ImplementationPosition)
            self.e7 = edge
            e7ImplementationCount = edge.implementationCount
        }
        totalImplementationCount += e7ImplementationCount


        return UpdateResult(
            implementationPosition: implementationPosition,
            implementationCount: totalImplementationCount
        )
    }

    public func make(element: Value) -> Value.Output {
        let input = Input()
        return Value.make(element, input: input)
    }

    public func shouldUpdate(with element: Value) -> Bool {
        // Pass through
        return true
    }
}
