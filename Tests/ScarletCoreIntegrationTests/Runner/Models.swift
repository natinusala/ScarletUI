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

@testable import ScarletCore

struct Specs<Value: Element> {
    let cases: [Case<Value>]
}

protocol UpdateAction {
    func run(on node: any ElementNode)
}

struct InitialSteps<Value: Element> {
    let initialView: Value.Node
    let updateActions: [any UpdateAction]
}

struct Case<Value: Element> {
    let initialSteps: () -> InitialSteps<Value>
    let description: String
    let expectations: [Expectations]
}

extension TestView {
    /// Creates a test case updating the view with a new version of itself.
    static func when(_ description: String, @ExpectationsBuilder expectations: () -> ((() -> InitialSteps<Self>), [Expectations])) -> Case<Self> {
        let (initialSteps, expectations) = expectations()

        return Case(
            initialSteps: initialSteps,
            description: description,
            expectations: expectations
        )
    }
}

/// Closure to run to assert that everything went as expected.
struct Expectations {
    let description: String
    let closure: (UpdateResult) -> Void
}

/// The result of an update operation. Passed to the test specs to assert
/// that everything went as expected.
struct UpdateResult {
    let bodyCalls: [ObjectIdentifier: Int]
    let implementation: ViewImpl?

    /// Only works after an update (is always empty after a creation).
    func bodyCalled<T>(of: T.Type) -> Bool {
        return (bodyCalls[ObjectIdentifier(T.self)] ?? 0) != 0
    }

    /// Only works after an update (is always empty after a creation).
    func bodyCalls<T>(of: T.Type) -> Int {
        return bodyCalls[ObjectIdentifier(T.self)] ?? 0
    }
}

extension TestView {
    /// Defines what must happen after the view is updated.
    static func then(_ description: String, expectations: @escaping (UpdateResult) -> Void) -> Expectations {
        return Expectations(description: description, closure: expectations)
    }
}

@resultBuilder
struct SpecsBuilder {
    static func buildBlock<Value: Element>(_ cases: Case<Value>...) -> Specs<Value> {
        return Specs(cases: cases)
    }
}

@resultBuilder
struct ExpectationsBuilder {
    /// Build a block with a starting view, an action then a list of expectations.
    static func buildBlock<Value: Element>(_ initial: @escaping (() -> InitialSteps<Value>), _ expectations: Expectations...) -> ((() -> InitialSteps<Value>), [Expectations]) {
        return (initial, expectations)
    }
}

extension TestView {
    static func given(@InitialBuilder _ initial: @escaping () -> (Self, [any UpdateAction])) -> (() -> InitialSteps<Self>) {
        return {
            let (initialView, updates) = initial()

            return InitialSteps(
                initialView: Self.makeNode(of: initialView, in: nil, implementationPosition: 0, using: .root()),
                updateActions: updates
            )
        }
    }
}

extension TestView {
    func run(on node: any ElementNode) {
        guard let node = node as? Self.Node else {
            fatalError("Tried to update \(Self.self) with node type \(type(of: node))")
        }

        _ = node.update(with: self, implementationPosition: 0, using: .root())
    }
}

@resultBuilder
struct InitialBuilder {
    static func buildBlock<V>(_ initial: V, _ actions: any UpdateAction...) -> (V, [any UpdateAction]) {
        return (initial, actions)
    }

    static func buildBlock<V>(_ initial: V) -> (V, [any UpdateAction]) {
        return (initial, [])
    }
}
