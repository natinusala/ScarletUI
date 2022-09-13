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

public struct StaticMakeInput4<Value>: MakeInput where Value: Element {

}

public struct StaticMakeOutput4<Value, E0, E1, E2, E3>: MakeOutput where Value: Element, E0: Element, E1: Element, E2: Element, E3: Element {
    var e0: E0
    var e1: E1
    var e2: E2
    var e3: E3
}

/// An element with static edges, aka. always the same amount of edges with the same type.
/// Performs no equality check on the element so its edges will always be updated ("passthrough" element).
public class StaticElementNode4<Value, E0, E1, E2, E3>: ElementNode where Value: Element, E0: Element, E1: Element, E2: Element, E3: Element, Value.Input == StaticMakeInput4<Value>, Value.Output == StaticMakeOutput4<Value, E0, E1, E2, E3> {
    typealias Input = StaticMakeInput4<Value>
    typealias Output = StaticMakeOutput4<Value, E0, E1, E2, E3>

    public var parent: (any ElementNode)?
    public var implementation: Value.Implementation?
    public var implementationCount = 0
    public var attributes = AttributesStash()

    var e0: E0.Node?
    var e1: E1.Node?
    var e2: E2.Node?
    var e3: E3.Node?

    init(making element: Value, in parent: (any ElementNode)?, implementationPosition: Int, using context: Context) {
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

        Logger.debug(debugImplementation, "\(E0.self) returned implementation count \(e0ImplementationCount) - Total: \(totalImplementationCount)")
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

        Logger.debug(debugImplementation, "\(E1.self) returned implementation count \(e1ImplementationCount) - Total: \(totalImplementationCount)")
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

        Logger.debug(debugImplementation, "\(E2.self) returned implementation count \(e2ImplementationCount) - Total: \(totalImplementationCount)")
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

        Logger.debug(debugImplementation, "\(E3.self) returned implementation count \(e3ImplementationCount) - Total: \(totalImplementationCount)")

        return UpdateResult(
            implementationPosition: implementationPosition,
            implementationCount: totalImplementationCount
        )
    }

    public func make(element: Value) -> Value.Output {
        let input = Input()
        return Value.make(element, input: input)
    }

    public var allEdges: [(any ElementNode)?] {
        return [
            self.e0,
            self.e1,
            self.e2,
            self.e3,
        ]
    }
}
