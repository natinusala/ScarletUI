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

import XCTest

@testable import ScarletCore

struct Specs<Value: ComponentModel> {
    let cases: [Case<Value>]
}

protocol UpdateAction {
    func run(on node: any ComponentNode)
}

struct InitialSteps<Value: ComponentModel> {
    let initialView: Value.Node
    let updateActions: [any UpdateAction]
}

struct Case<Value: ComponentModel> {
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
    let target: ViewTarget?

    /// Only works after an update (is always empty after a creation).
    func bodyCalled<T>(of: T.Type) -> Bool {
        return (bodyCalls[ObjectIdentifier(T.self)] ?? 0) != 0
    }

    /// Only works after an update (is always empty after a creation).
    func bodyCalls<T>(of: T.Type) -> Int {
        return bodyCalls[ObjectIdentifier(T.self)] ?? 0
    }

    /// Children of the `Tested` struct.
    var testedChildren: [ViewTarget] {
        guard let target else {
            XCTFail("Expected an target with children but got no target")
            return []
        }

        return target.children
    }

    /// Traverses the view tree and returns the first view with the given type.
    func first<NewType: ViewTarget>(_ type: NewType.Type) -> NewType {
        guard let target else {
            fatalError("Expected an target with children but got no target")
        }

        return target.findFirst(type)
    }

    /// Traverses the view tree and returns the first view with the given display name.
    func first(_ displayName: String) -> ViewTarget {
        guard let target else {
            fatalError("Expected an target with children but got no target")
        }

        return target.findFirst(displayName)
    }

    /// Traverses the view tree recursively and returns all views of the given type.
    /// Will fail the test if it did not find exactly ``expectedCount`` views.
    func all<NewType: ViewTarget>(_ type: NewType.Type, expectedCount: Int) -> [NewType] {
        guard let target else {
            fatalError("Expected an target with children but got no target")
        }

        return target.findAll(type, expectedCount: expectedCount)
    }

    /// Returns a flat list of all views of the result.
    func allViews() -> [ViewTarget] {
        guard let target else {
            fatalError("Expected an target but got no target")
        }

        return [target] + target.allChildren()
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
    static func buildBlock<Value: ComponentModel>(_ cases: Case<Value>...) -> Specs<Value> {
        return Specs(cases: cases)
    }
}

@resultBuilder
struct ExpectationsBuilder {
    /// Build a block with a starting view, an action then a list of expectations.
    static func buildBlock<Value: ComponentModel>(_ initial: @escaping (() -> InitialSteps<Value>), _ expectations: Expectations...) -> ((() -> InitialSteps<Value>), [Expectations]) {
        return (initial, expectations)
    }
}

extension TestView {
    static func given(@InitialBuilder _ initial: @escaping () -> (Self, [any UpdateAction])) -> (() -> InitialSteps<Self>) {
        return {
            let (initialView, updates) = initial()

            return InitialSteps(
                initialView: Self.makeNode(of: initialView, in: nil, targetPosition: 0, using: .root()),
                updateActions: updates
            )
        }
    }
}

extension TestView {
    func run(on node: any ComponentNode) {
        guard let node = node as? Self.Node else {
            fatalError("Tried to update '\(Self.self)' with node type '\(type(of: node))'")
        }

        let context = ComponentContext.root()

        var installed = self
        node.install(component: &installed, using: context)

        _ = node.update(with: installed, targetPosition: 0, using: context)
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
