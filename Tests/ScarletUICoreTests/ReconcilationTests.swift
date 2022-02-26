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

// TODO: check every case (insert, remove, update) for optional, tupleview, conditional... as well as more complicated cases to check offsets

/// Add every test case here
let cases: [ReconcilationTestCase.Type] = [
    NoInputTestCase.self,
    UpdateTestCase.self,
    OffsetsTestCase.self,
    OptionalUpdateTestCase.self,
    OptionalInsertionTestCase.self,
    OptionalDeletionTestCase.self,
]

/// Tests insertions, deletions and updates on large tuple views to test
/// the offset mechanism on tuple views, optionals and conditionals.
/// TODO: add if / elses somewhere to test conditionals once they are implemented
struct OffsetsTestCase: ReconcilationTestCase {
    struct TestView: View, Equatable {
        var detailed: Bool

        var body: some View {
            Column {
                // Header
                Row {
                    Image(source: "mainLogo.png")
                    Text(detailed ? "App Title (debug)" : "App Title")

                    Divider()

                    Text("Logged in as: FooBarBaz")

                    if detailed {
                        Divider()

                        Text("Unread messages: 7")
                        Text("Update available!")
                    }

                    Divider()

                    Text("X: Close")
                }

                Divider()

                // Body
                Row {
                    Column {
                        Text("Unread (7)")
                        Text("Sent")

                        if !detailed {
                            Divider()

                            Text("Enable detailed mode to see spam")
                        }

                        Divider()

                        Text("Settings")
                    }
                }

                Divider()

                // Footer
                Row {
                    Text(detailed ? "Controller 1: Keyboard / Mouse" : "Keyboard / Mouse")
                    Text(detailed ?  "P1 A: OK" : "A: OK")
                    Text(detailed ?  "P1 B: Back" : "B: Back")
                }

                // Debug bar
                if detailed {
                    Row {
                        Text("Debug bar")
                        Text("Memory: 74mB")
                        Text("CPU Usage: 2%")
                        Text("GPU Usage: 1%")
                    }
                }
            }
        }
    }

    static var initialView: TestView {
        TestView(detailed: false)
    }

    static var expectedInitialTree: some View {
        Column {
            // Header
            Row {
                Image(source: "mainLogo.png")
                Text("App Title")

                Divider()

                Text("Logged in as: FooBarBaz")

                if false {
                    Divider()

                    Text("Unread messages: 7")
                    Text("Update available!")
                }

                Divider()

                Text("X: Close")
            }

            Divider()

            // Body
            Row {
                Column {
                    Text("Unread (7)")
                    Text("Sent")

                    if true {
                        Divider()

                        Text("Enable detailed mode to see spam")
                    }

                    Divider()

                    Text("Settings")
                }
            }

            Divider()

            // Footer
            Row {
                Text("Keyboard / Mouse")
                Text("A: OK")
                Text("B: Back")
            }

            // Debug bar
            if false {
                Row {
                    Text("Debug bar")
                    Text("Memory: 74mB")
                    Text("CPU Usage: 2%")
                    Text("GPU Usage: 1%")
                }
            }
        }
    }

    static var updatedView: TestView {
        TestView(detailed: true)
    }

    static var expectedUpdatedTree: some View {
        Column {
            // Header
            Row {
                Image(source: "mainLogo.png")
                Text("App Title (debug)")

                Divider()

                Text("Logged in as: FooBarBaz")

                if true {
                    Divider()

                    Text("Unread messages: 7")
                    Text("Update available!")
                }

                Divider()

                Text("X: Close")
            }

            Divider()

            // Body
            Row {
                Column {
                    Text("Unread (7)")
                    Text("Sent")

                    if false {
                        Divider()

                        Text("Enable detailed mode to see spam")
                    }

                    Divider()

                    Text("Settings")
                }
            }

            Divider()

            // Footer
            Row {
                Text("Controller 1: Keyboard / Mouse")
                Text("P1 A: OK")
                Text("P1 B: Back")
            }

            // Debug bar
            if true {
                Row {
                    Text("Debug bar")
                    Text("Memory: 74mB")
                    Text("CPU Usage: 2%")
                    Text("GPU Usage: 1%")
                }
            }
        }
    }
}

/// Checks that the views are updated.
struct UpdateTestCase: ReconcilationTestCase {
    struct TestView: View, Equatable {
        var urlPrefix: String

        var body: some View {
            Column {
                Image(source: urlPrefix + "1")
                Image(source: urlPrefix + "2")
                Image(source: urlPrefix + "3")
                Image(source: "static")
            }
        }
    }

    static var initialView: TestView {
        TestView(urlPrefix: "url")
    }

    static var expectedInitialTree: some View {
        Column {
            Image(source: "url1")
            Image(source: "url2")
            Image(source: "url3")
            Image(source: "static")
        }
    }

    static var updatedView: TestView {
        TestView(urlPrefix: "file")
    }

    static var expectedUpdatedTree: some View {
        Column {
            Image(source: "file1")
            Image(source: "file2")
            Image(source: "file3")
            Image(source: "static")
        }
    }
}

/// Test case for a view that has no input and therefore cannot change.
struct NoInputTestCase: ReconcilationTestCase {
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

/// Test case for a view that has an optional part in its body that gets updated.
struct OptionalUpdateTestCase: ReconcilationTestCase {
    struct TestView: View, Equatable {
        var hasImageRow: Bool
        var imageUrl: String

        var body: some View {
            Column {
                if hasImageRow {
                    Row {
                        Image(source: imageUrl)
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
        TestView(hasImageRow: true, imageUrl: "http://website.com/picture.png")
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
        TestView(hasImageRow: true, imageUrl: "http://anotherwebsite.net/picture2.png")
    }

    static var expectedUpdatedTree: some View {
        Column {
            if true {
                Row {
                    Image(source: "http://anotherwebsite.net/picture2.png")
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
struct OptionalInsertionTestCase: ReconcilationTestCase {
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
struct OptionalDeletionTestCase: ReconcilationTestCase {
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
        let description = "mounted views count of \(self.body.viewType) is different (\(self.listMountedViews()) VS. \(other.listMountedViews()))"
        expect(self.mountedViews.count).to(equal(other.mountedViews.count), description: description)

        for (lhs, rhs) in zip(self.mountedViews, other.mountedViews) {
            lhs.expectToBe(rhs)
        }
    }

    func listMountedViews() -> String {
        return "[\(self.mountedViews.map {$0.description}.joined(separator: ", "))]"
    }
}

extension AnyView {
    /// Runs assertions to check that this view is equal to the given one.
    func expectToBe(_ other: AnyView, propertyName: String) {
        // First compare view type
        if self.viewType != other.viewType {
            XCTFail("when comparing \(propertyName), view has a different type: got \(self.viewType) and \(other.viewType)")
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

struct Divider: View, Equatable {
    typealias Body = Never
}
