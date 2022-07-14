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

extension TestView {
    func updateWith(action: @escaping () -> Self) -> UpdateAction {
        return { node in
            let newView = action()
            node.update(with: newView, attributes: [:])
        }
    }

    func create() -> UpdateAction {
        return { _ in }
    }
}

struct Case {
    let description: String
    let action: UpdateAction
    let expectations: [Expectations]
}

extension TestView {
    /// Creates a test case updating the view with a new version of itself.
    func when(_ description: String, @ExpectationsBuilder expectations: () -> (UpdateAction, [Expectations])) -> Case {
        let (action, expectations) = expectations()

        return Case(
            description: description,
            action: action,
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

    func bodyCalled<T>(of: T.Type) -> Bool {
        return (bodyCalls[ObjectIdentifier(T.self)] ?? 0) != 0
    }

    func bodyCalls<T>(of: T.Type) -> Int {
        return bodyCalls[ObjectIdentifier(T.self)] ?? 0
    }
}


extension TestView {
    /// Defines what must happen after the view is updated.
    func then(_ description: String, expectations: @escaping (UpdateResult) -> Void) -> Expectations {
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
    static func buildBlock(_ action: @escaping UpdateAction, _ expectations: Expectations...) -> (UpdateAction, [Expectations]) {
        return (action, expectations)
    }
}