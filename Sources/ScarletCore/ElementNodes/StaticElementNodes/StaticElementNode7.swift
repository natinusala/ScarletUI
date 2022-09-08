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

public struct StaticMakeInput7<Value>: MakeInput where Value: Element {

}

public struct StaticMakeOutput7<Value, E0, E1, E2, E3, E4, E5, E6>: MakeOutput where Value: Element, E0: Element, E1: Element, E2: Element, E3: Element, E4: Element, E5: Element, E6: Element {
    var e0: E0
    var e1: E1
    var e2: E2
    var e3: E3
    var e4: E4
    var e5: E5
    var e6: E6
}

/// An element with static edges, aka. always the same amount of edges with the same type.
/// Performs no equality check on the element so its edges will always be updated ("passthrough" element).
public class StaticElementNode7<Value, E0, E1, E2, E3, E4, E5, E6>: ElementNode where Value: Element, E0: Element, E1: Element, E2: Element, E3: Element, E4: Element, E5: Element, E6: Element, Value.Input == StaticMakeInput7<Value>, Value.Output == StaticMakeOutput7<Value, E0, E1, E2, E3, E4, E5, E6> {
    typealias Input = StaticMakeInput7<Value>
    typealias Output = StaticMakeOutput7<Value, E0, E1, E2, E3, E4, E5, E6>

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

    init(making element: Value, in parent: (any ElementNode)?, implementationPosition: Int, using context: Context) {
        self.value = element
        self.parent = parent

        // Create the implementation node
        self.implementation = Value.makeImplementation(of: element)

        // Start a first update without comparing (since we update the value with itself)
        let result = self.update(with: element, implementationPosition: implementationPosition, using: context)

        // Attach the implementation once everything is ready
        self.attachImplementationToParent(position: result.implementationPosition)
    }

    public func updateEdges(from output: Value.Output?, at implementationPosition: Int, using context: Context) -> UpdateResult {
        // Create edges if updating for the first time
        // Otherwise update them

        var totalImplementationCount = 0

        // Edge 0
        let e0ImplementationPosition = implementationPosition + totalImplementationCount
        let e0ImplementationCount: Int
        if let e0 = self.e0 {
            e0ImplementationCount = e0.installAndUpdate(
                with: output?.e0,
                implementationPosition: e0ImplementationPosition,
                using: context
            ).implementationCount
        } else if let output {
            let edge = E0.makeNode(of: output.e0, in: self, implementationPosition: e0ImplementationPosition, using: context)
            self.e0 = edge
            e0ImplementationCount = edge.implementationCount
        } else {
            nilOutputFatalError(for: E0.self)
        }
        totalImplementationCount += e0ImplementationCount

        // Edge 1
        let e1ImplementationPosition = implementationPosition + totalImplementationCount
        let e1ImplementationCount: Int
        if let e1 = self.e1 {
            e1ImplementationCount = e1.installAndUpdate(
                with: output?.e1,
                implementationPosition: e1ImplementationPosition,
                using: context
            ).implementationCount
        } else if let output {
            let edge = E1.makeNode(of: output.e1, in: self, implementationPosition: e1ImplementationPosition, using: context)
            self.e1 = edge
            e1ImplementationCount = edge.implementationCount
        } else {
            nilOutputFatalError(for: E1.self)
        }
        totalImplementationCount += e1ImplementationCount

        // Edge 2
        let e2ImplementationPosition = implementationPosition + totalImplementationCount
        let e2ImplementationCount: Int
        if let e2 = self.e2 {
            e2ImplementationCount = e2.installAndUpdate(
                with: output?.e2,
                implementationPosition: e2ImplementationPosition,
                using: context
            ).implementationCount
        } else if let output {
            let edge = E2.makeNode(of: output.e2, in: self, implementationPosition: e2ImplementationPosition, using: context)
            self.e2 = edge
            e2ImplementationCount = edge.implementationCount
        } else {
            nilOutputFatalError(for: E2.self)
        }
        totalImplementationCount += e2ImplementationCount

        // Edge 3
        let e3ImplementationPosition = implementationPosition + totalImplementationCount
        let e3ImplementationCount: Int
        if let e3 = self.e3 {
            e3ImplementationCount = e3.installAndUpdate(
                with: output?.e3,
                implementationPosition: e3ImplementationPosition,
                using: context
            ).implementationCount
        } else if let output {
            let edge = E3.makeNode(of: output.e3, in: self, implementationPosition: e3ImplementationPosition, using: context)
            self.e3 = edge
            e3ImplementationCount = edge.implementationCount
        } else {
            nilOutputFatalError(for: E3.self)
        }
        totalImplementationCount += e3ImplementationCount

        // Edge 4
        let e4ImplementationPosition = implementationPosition + totalImplementationCount
        let e4ImplementationCount: Int
        if let e4 = self.e4 {
            e4ImplementationCount = e4.installAndUpdate(
                with: output?.e4,
                implementationPosition: e4ImplementationPosition,
                using: context
            ).implementationCount
        } else if let output {
            let edge = E4.makeNode(of: output.e4, in: self, implementationPosition: e4ImplementationPosition, using: context)
            self.e4 = edge
            e4ImplementationCount = edge.implementationCount
        } else {
            nilOutputFatalError(for: E4.self)
        }
        totalImplementationCount += e4ImplementationCount

        // Edge 5
        let e5ImplementationPosition = implementationPosition + totalImplementationCount
        let e5ImplementationCount: Int
        if let e5 = self.e5 {
            e5ImplementationCount = e5.installAndUpdate(
                with: output?.e5,
                implementationPosition: e5ImplementationPosition,
                using: context
            ).implementationCount
        } else if let output {
            let edge = E5.makeNode(of: output.e5, in: self, implementationPosition: e5ImplementationPosition, using: context)
            self.e5 = edge
            e5ImplementationCount = edge.implementationCount
        } else {
            nilOutputFatalError(for: E5.self)
        }
        totalImplementationCount += e5ImplementationCount

        // Edge 6
        let e6ImplementationPosition = implementationPosition + totalImplementationCount
        let e6ImplementationCount: Int
        if let e6 = self.e6 {
            e6ImplementationCount = e6.installAndUpdate(
                with: output?.e6,
                implementationPosition: e6ImplementationPosition,
                using: context
            ).implementationCount
        } else if let output {
            let edge = E6.makeNode(of: output.e6, in: self, implementationPosition: e6ImplementationPosition, using: context)
            self.e6 = edge
            e6ImplementationCount = edge.implementationCount
        } else {
            nilOutputFatalError(for: E6.self)
        }
        totalImplementationCount += e6ImplementationCount


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

    public var allEdges: [(any ElementNode)?] {
        return [
            self.e0,
            self.e1,
            self.e2,
            self.e3,
            self.e4,
            self.e5,
            self.e6,
        ]
    }
}
