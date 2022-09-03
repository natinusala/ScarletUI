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

public struct StaticMakeInput2<Value>: MakeInput where Value: Element {

}

public struct StaticMakeOutput2<Value, E0, E1>: MakeOutput where Value: Element, E0: Element, E1: Element {
    var e0: E0
    var e1: E1
}

/// An element with static edges, aka. always the same amount of edges
/// with the same type.
public class StaticElementNode2<Value, E0, E1>: ElementNode where Value: Element, E0: Element, E1: Element, Value.Input == StaticMakeInput2<Value>, Value.Output == StaticMakeOutput2<Value, E0, E1> {
    typealias Input = StaticMakeInput2<Value>
    typealias Output = StaticMakeOutput2<Value, E0, E1>

    public var value: Value
    public var parent: (any ElementNode)?
    public var implementation: Value.Implementation?
    public var implementationCount = 0

    var e0: E0.Node?
    var e1: E1.Node?

    init(making element: Value, in parent: (any ElementNode)?, implementationPosition: Int) {
        self.value = element

        // Start a first update without comparing (since we update the value with itself)
        let result = self.update(with: element, compare: false, implementationPosition: implementationPosition)

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
            e0ImplementationCount = e0.update(with: output.e0, compare: true, implementationPosition: e0ImplementationPosition).implementationCount
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
            e1ImplementationCount = e1.update(with: output.e1, compare: true, implementationPosition: e1ImplementationPosition).implementationCount
        } else {
            let edge = E1.makeNode(of: output.e1, in: self, implementationPosition: e1ImplementationPosition)
            self.e1 = edge
            e1ImplementationCount = edge.implementationCount
        }
        totalImplementationCount += e1ImplementationCount


        return UpdateResult(
            implementationPosition: implementationPosition,
            implementationCount: totalImplementationCount
        )
    }

    public func make(element: Value) -> Value.Output {
        let input = Input()
        return Value.make(element, input: input)
    }
}
