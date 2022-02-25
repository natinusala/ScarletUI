/**
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

import Foundation
import XCTest

import Quick
import Nimble

@testable import ScarletUICore

// TODO: use a mock on the implementation to see if `update()`, `insert()` and `remove()` are called (remember to test that unnecessary updates are not performed if the view is equal)

// TODO: check update (use a if inside Image(...) to change the URL)

/// Add every test case here
let cases: [ReconcilationTestCase.Type] = [
    NoInputTest.self,
    OptionalInsertionTest.self,
    OptionalDeletionTest.self,
]

/// Test case for a view that has no input and therefore cannot change.
struct NoInputTest: ReconcilationTestCase {
    struct TestView: View, Equatable {
        var body: some View {
            Column {
                Row {
                    Image(source: "http://website.com/picture.png")
                }
                Row {
                    Text("Text 1")
                    Text("Text 2")
                    Text("Text 3")
                }
            }
        }
    }

    static var initialView: TestView {
        TestView()
    }

    static var expectedInitialTree: some View {
        Column {
            Row {
                Image(source: "http://website.com/picture.png")
            }
            Row {
                Text("Text 1")
                Text("Text 2")
                Text("Text 3")
            }
        }
    }

    static var updatedView: TestView {
        TestView()
    }

    static var expectedUpdatedTree: some View {
        Column {
            Row {
                Image(source: "http://website.com/picture.png")
            }
            Row {
                Text("Text 1")
                Text("Text 2")
                Text("Text 3")
            }
        }
    }
}

/// Test case for a view that has an optional part in its body that gets inserted.
struct OptionalInsertionTest: ReconcilationTestCase {
    struct TestView: View, Equatable {
        var hasImageRow: Bool

        var body: some View {
            Column {
                if hasImageRow {
                    Row {
                        Image(source: "http://website.com/picture.png")
                    }
                }
                Row {
                    Text("Text 1")
                    Text("Text 2")
                    Text("Text 3")
                }
            }
        }
    }

    static var initialView: TestView {
        TestView(hasImageRow: false)
    }

    static var expectedInitialTree: some View {
        Column {
            if false {
                Row {
                    Image(source: "http://website.com/picture.png")
                }
            }
            Row {
                Text("Text 1")
                Text("Text 2")
                Text("Text 3")
            }
        }
    }

    static var updatedView: TestView {
        TestView(hasImageRow: true)
    }

    static var expectedUpdatedTree: some View {
        Column {
            if true {
                Row {
                    Image(source: "http://website.com/picture.png")
                }
            }
            Row {
                Text("Text 1")
                Text("Text 2")
                Text("Text 3")
            }
        }
    }
}

/// Test case for a view that has an optional part in its body that gets inserted.
struct OptionalDeletionTest: ReconcilationTestCase {
    struct TestView: View, Equatable {
        var hasImageRow: Bool

        var body: some View {
            Column {
                if hasImageRow {
                    Row {
                        Image(source: "http://website.com/picture.png")
                    }
                }
                Row {
                    Text("Text 1")
                    Text("Text 2")
                    Text("Text 3")
                }
            }
        }
    }

    static var initialView: TestView {
        TestView(hasImageRow: true)
    }

    static var expectedInitialTree: some View {
        Column {
            if true {
                Row {
                    Image(source: "http://website.com/picture.png")
                }
            }
            Row {
                Text("Text 1")
                Text("Text 2")
                Text("Text 3")
            }
        }
    }

    static var updatedView: TestView {
        TestView(hasImageRow: false)
    }

    static var expectedUpdatedTree: some View {
        Column {
            if false {
                Row {
                    Image(source: "http://website.com/picture.png")
                }
            }
            Row {
                Text("Text 1")
                Text("Text 2")
                Text("Text 3")
            }
        }
    }
}

/// Tests for the "reconcilation" process, aka. evaluating a view's body and applying changes when its inputs change.
/// Each test takes an initial view, constructs the initial tree and controls it. Then the
/// view input is changed, the body is re-evaluated and the resulting tree is controlled.
class ReconcilationSpecs: QuickSpec {
    override func spec() {
        for testCase in cases {
            describe("\(testCase)") {
                it("creates the initial view tree") {
                    var node = testCase.initialViewBodyNode
                    node.initialMount()

                    var expectedNode = testCase.expectedInitialViewBodyNode
                    expectedNode.initialMount()

                    node.expectToBe(expectedNode)
                }

                it("applies updates") {
                    // Create and mount initial node
                    var node = testCase.initialViewNode
                    node.initialMount()

                    // Create updated node, apply updates to the initial node
                    let updatedNode = testCase.updatedViewNode
                    node.update(next: updatedNode)

                    // Create initial node
                    var expectedNode = testCase.expectedUpdatedViewBodyNode
                    expectedNode.initialMount()

                    // Assert that the 1st mounted view (our initial view) is now updated
                    node.mountedViews[0].children!.expectToBe(expectedNode)
                }
            }
        }
    }
}

protocol ReconcilationTestCase {
    /// The type of the view tested in this test case.
    associatedtype TestedView: View

    /// The type of the view for the initially tested tree.
    associatedtype InitialTree: View

    /// The type of the view for the initially tested tree.
    associatedtype UpdatedTree: View

    /// The `TestedView` instance initially created.
    static var initialView: TestedView { get }

    /// The full expected tree after creating the initial view.
    static var expectedInitialTree: InitialTree { get }

    /// The `TestedView` instance of the updated version of `initialView`.
    static var updatedView: TestedView { get }

    /// The expected tree after updating the initial view with the updated one.
    static var expectedUpdatedTree: UpdatedTree { get }
}

extension ReconcilationTestCase {
    /// Creates the body node for the initial view's body for this test case
    /// (not the initial view itself, but its body).
    static var initialViewBodyNode: BodyNode {
        return BodyNode(of: Self.initialView.body)
    }

    /// Creates the expected body node for the initial view's body for this test case.
    static var expectedInitialViewBodyNode: BodyNode {
        return BodyNode(of: Self.expectedInitialTree)
    }

    /// Creates the body node for the initial view for this test case
    /// (the actual initial view).
    static var initialViewNode: BodyNode {
        return BodyNode(of: Self.initialView)
    }

    /// Creates the body node for the updated view for this test case.
    static var updatedViewNode: BodyNode {
        return BodyNode(of: Self.updatedView)
    }

    /// Creates the expected body node for the updated view for this test case.
    static var expectedUpdatedViewBodyNode: BodyNode {
        return BodyNode(of: Self.expectedUpdatedTree)
    }
}

extension BodyNode {
    /// Runs assertions to check that this body node is equal to the given one.
    func expectToBe(_ other: BodyNode) {
        // Check that `body` is equal
        self.body.expectToBe(other.body, propertyName: "`BodyNode` body")

        // Check that every mounted view is equal
        expect(self.mountedViews.count).to(equal(other.mountedViews.count), description: "mounted views count is different")

        for (lhs, rhs) in zip(self.mountedViews, other.mountedViews) {
            lhs.expectToBe(rhs)
        }
    }
}

extension AnyView {
    /// Runs assertions to check that this view is equal to the given one.
    func expectToBe(_ other: AnyView, propertyName: String) {
        // First compare view type
        if self.viewType != other.viewType {
            XCTFail("view has a different type: got \(self.viewType), got \(other.viewType)")
        } else {
            // Then compare field by field
            if !self.equalsClosure(self.view, other) {
                XCTFail("when comparing \(propertyName), \(self.viewType) is different")
            }
        }
    }
}

extension MountedView {
    /// Runs assertions to check that this mounted view is equal to the given one.
    func expectToBe(_ other: MountedView) {
        // Check that the view is equal
        self.view.expectToBe(other.view, propertyName: "`MountedView` view")

        // Check that the body node is equal
        self.children.expectToBe(other.children)
    }
}

extension Optional where Wrapped == BodyNode {
    func expectToBe(_ other: BodyNode?) {
        switch (self, other) {
            case (.none, .some), (.some, .none):
                XCTFail("Children body node is different")
            case let (.some(lhs), .some(rhs)):
                lhs.expectToBe(rhs)
            case (.none, .none):
                break // All good, nothing to do
        }
    }
}

// MARK: Dummy views for testing

struct Text: View, Equatable {
    let text: String
    typealias Body = Never

    init(_ text: String) {
        self.text = text
    }
}

struct Image: View, Equatable {
    let source: String
    typealias Body = Never
}

struct Column<Content>: View, EquatableStruct where Content: View {
    var content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        self.content
    }

    /// Usually generated.
    static func equals(lhs: Self, rhs: Self) -> Bool {
        return Content.equals(lhs: lhs.content, rhs: rhs.content)
    }
}

struct Row<Content>: View, EquatableStruct where Content: View {
    var content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        self.content
    }

    /// Usually generated.
    static func equals(lhs: Self, rhs: Self) -> Bool {
        return Content.equals(lhs: lhs.content, rhs: rhs.content)
    }
}
