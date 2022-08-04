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

struct Specs {
    let cases: [Case]
}

typealias UpdateAction = (ElementNode) -> ()

struct InitialSteps {
    let initialView: ElementNode
    let updateActions: [UpdateAction]
}

struct Case {
    let initialSteps: () -> InitialSteps
    let description: String
    let expectations: [Expectations]
}

extension TestView {
    /// Creates a test case updating the view with a new version of itself.
    static func when(_ description: String, @ExpectationsBuilder expectations: () -> ((() -> InitialSteps), [Expectations])) -> Case {
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
    static func buildBlock(_ cases: Case...) -> Specs {
        return Specs(cases: cases)
    }
}

@resultBuilder
struct ExpectationsBuilder {
    /// Build a block with a starting view, an action then a list of expectations.
    static func buildBlock(_ initial: @escaping (() -> InitialSteps), _ expectations: Expectations...) -> ((() -> InitialSteps), [Expectations]) {
        return (initial, expectations)
    }
}

extension TestView {
    static func given(@InitialBuilder _ initial: @escaping () -> (Self, [Self])) -> (() -> InitialSteps) {
        return {
            let (initialView, updates) = initial()

            return InitialSteps(
                initialView: ElementNode(parent: nil, making: initialView),
                updateActions: updates.map { newValue in
                    return { element in
                        element.update(with: newValue, attributes: [:])
                    }
                }
            )
        }
    }
}

@resultBuilder
struct InitialBuilder {
    static func buildBlock<V>(_ initial: V, _ values: V...) -> (V, [V]) {
        return (initial, values)
    }

    static func buildBlock<V>(_ initial: V) -> (V, [V]) {
        return (initial, [])
    }
}
