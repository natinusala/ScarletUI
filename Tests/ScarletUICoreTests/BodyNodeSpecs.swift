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

import Foundation
import XCTest

import Quick
import Nimble

@testable import ScarletUICore

// TODO: Use a mock on the implementation to see if `update()`, `insert()` and `remove()` are called (remember to test that unnecessary updates are not performed if the view is equal)

/// Add every test case here
fileprivate let cases: [BodyNodeTestCase.Type] = [
    // // Generic cases
    // NoInputTestCase.self,
    // UpdateTestCase.self,
    // OffsetsTestCase.self,
    // NestedViewTestCase.self,
    // // Optional cases
    // OptionalUpdateTestCase.self,
    // OptionalInsertionTestCase.self,
    // OptionalRemovalTestCase.self,
    // OptionalUnchangedTestCase.self,
    // NestedOptionalInsertionTestCase.self,
    // NestedOptionalRemovalTestCase.self,
    // NestedOptionalUpdateTestCase.self,
    // // Conditional cases
    // UnbalancedConditionalTestCase.self,
    // BalancedConditionalTestCase.self,
    // ConditionalRemoveOptionalTestCase.self,
    // ConditionalAddOptionalTestCase.self,
    // EmptyFirstAddSecondConditionalTestCase.self,
    // EmptyFirstRemoveSecondConditionalTestCase.self,
    // EmptySecondAddFirstConditionalTestCase.self,
    // EmptySecondRemoveFirstConditionalTestCase.self,
    // NestedConditionalsTestCase.self,
    // Edge cases identified by fuzzer
    TOBENAMED.self,
]

struct TOBENAMED: BodyNodeTestCase {
    struct Picture: View, Equatable {
        let variable0: Int

        var body: some View {
            Image(source: "https://pictures.com/picture\(variable0).jpg")
        }
    }
    struct TestView: View, Equatable {
        let flip0: Bool
        let flip1: Bool
        let variable0: Int
        let variable1: Int
        let variable2: Int
        let variable3: Int
        let variable4: Int

        var body: some View {
            Row {
                Row {
                    // 0
                    if flip0 {
                        Text("Mouse")
                    } else {
                        Text("Doug")
                    }
                    // 1
                    if flip0 {
                        Text("Cat")
                    } else if flip0 {
                        Text("Apple")
                    } else if flip1 {
                        Image(source: "https://pictures.com/Switch.jpg")
                    } else if flip1 {
                        Image(source: "https://pictures.com/picture\(variable0).jpg")
                    }
                    // 2
                    Column {
                        Picture(variable0: variable1)
                        Text("variable1=\(variable1)")
                    }
                    // 3
                    Picture(variable0: 91)
                    // 4
                    Text("variable0=\(variable0)")
                    if flip1 {
                        Text("Chocolate")
                    } else if flip0 {
                        Text("variable1=\(variable1)")
                    } else if flip1 {
                        Text("variable1=\(variable1)")
                    }
                    Row {
                        Text("Pear")
                        Text("variable2=\(variable2)")
                        Picture(variable0: variable3)
                        Picture(variable0: variable1)
                    }
                    Image(source: "https://pictures.com/picture\(variable4).jpg")
                }
            }
        }
    }

    static var initialView: TestView {
        TestView(flip0: false, flip1: false, variable0: 42, variable1: 227, variable2: 28, variable3: 165, variable4: 97)
    }

    static var expectedInitialTree: some View {
        Row {
            Row {
                // 0
                if false {
                    Text("Mouse")
                } else {
                    Text("Doug")
                }
                // 1
                if false {
                    Text("Cat")
                } else if false {
                    Text("Apple")
                } else if false {
                    Image(source: "https://pictures.com/Switch.jpg")
                } else if false {
                    Image(source: "https://pictures.com/picture42.jpg")
                }
                // 2
                Column {
                    Picture(variable0: 227)
                    Text("variable1=227")
                }
                // 3
                Picture(variable0: 91)
                // 4
                Text("variable0=42")
                // 5
                if false {
                    Text("Chocolate")
                } else if false {
                    Text("variable1=227")
                } else if false {
                    Text("variable1=227")
                }
                Row {
                    Text("Pear")
                    Text("variable2=28")
                    Picture(variable0: 165)
                    Picture(variable0: 227)
                }
                Image(source: "https://pictures.com/picture97.jpg")
            }
        }
    }

    static var updatedView: TestView {
        TestView(flip0: true, flip1: true, variable0: 149, variable1: 195, variable2: 59, variable3: 101, variable4: 3)
    }

    static var expectedUpdatedTree: some View {
        Row {
            Row {
                if true {
                    Text("Mouse")
                } else {
                    Text("Doug")
                }
                if true {
                    Text("Cat")
                } else if true {
                    Text("Apple")
                } else if true {
                    Image(source: "https://pictures.com/Switch.jpg")
                } else if true {
                    Image(source: "https://pictures.com/picture149.jpg")
                }
                Column {
                    Picture(variable0: 195)
                    Text("variable1=195")
                }
                Picture(variable0: 91)
                Text("variable0=149")
                if true {
                    Text("Chocolate")
                } else if true {
                    Text("variable1=195")
                } else if true {
                    Text("variable1=195")
                }
                Row {
                    Text("Pear")
                    Text("variable2=59")
                    Picture(variable0: 101)
                    Picture(variable0: 195)
                }
                Image(source: "https://pictures.com/picture3.jpg")
            }
        }
    }
}

/// Test with multiple internal views.
struct NestedViewTestCase: BodyNodeTestCase {
    struct TestView: View, Equatable {
        var counter: Int

        var body: some View {
            Row {
                if counter == 0 {
                    Text("You are dead!")
                } else {
                    Text("Status:")
                    LivesCounter(counter: counter)
                }
            }
        }
    }

    struct LivesCounter: View, Equatable {
        var counter: Int

        var body: some View {
            Text("\(counter) lives left")
        }
    }

    static var initialView: TestView {
        TestView(counter: 3)
    }

    static var expectedInitialTree: some View {
        Row {
            if false {
                Text("You are dead!")
            } else {
                Text("Status:")
                LivesCounter(counter: 3)
            }
        }
    }

    static var updatedView: TestView {
        TestView(counter: 2)
    }

    static var expectedUpdatedTree: some View {
        Row {
            if false {
                Text("You are dead!")
            } else {
                Text("Status:")
                LivesCounter(counter: 2)
            }
        }
    }
}

/// Tests nested conditionals (else-ifs).
struct NestedConditionalsTestCase: BodyNodeTestCase {
    struct TestView: View, Equatable {
        var value: Int

        var body: some View {
            Row {
                if value > 20 {
                    Text("Value is > 20")

                    if value > 30 {
                        Text("Value is > 30")
                    } else if value > 25 {
                        Text("Value is > 25")
                    }
                } else if value > 10 {
                    Text("Value is > 10")

                    if value > 15 {
                        Text("Value is > 15")
                    }
                } else {
                    Text("Value is unknown")
                }
            }
        }
    }

    static var initialView: TestView {
        TestView(value: 16)
    }

    static var expectedInitialTree: some View {
        Row {
            if false {
                Text("Value is > 20")

                if false {
                    Text("Value is > 30")
                } else if false {
                    Text("Value is > 25")
                }
            } else if true {
                Text("Value is > 10")

                if true {
                    Text("Value is > 15")
                }
            } else {
                Text("Value is unknown")
            }
        }
    }

    static var updatedView: TestView {
        TestView(value: 35)
    }

    static var expectedUpdatedTree: some View {
        Row {
            if true {
                Text("Value is > 20")

                if true {
                    Text("Value is > 30")
                } else if false {
                    Text("Value is > 25")
                }
            } else if false {
                Text("Value is > 10")

                if false {
                    Text("Value is > 15")
                }
            } else {
                Text("Value is unknown")
            }
        }
    }
}

/// Tests that all views are removed and added in a "balanced" conditional.
struct BalancedConditionalTestCase: BodyNodeTestCase {
    struct TestView: View, Equatable {
        var flip: Bool

        var body: some View {
            Row {
                if flip {
                    Text("Text 1")
                    Text("Text 2")

                    Image(source: "icon")

                    Column {
                        Text("Subtext 1")
                        Text("Subtext 2")
                    }
                } else {
                    Text("Label 1")
                    Text("Label 2")

                    Image(source: "logo")

                    Column {
                        Text("Subtitle 1")
                        Text("Subtitle 2")
                    }
                }
            }
        }
    }

    static var initialView: TestView {
        TestView(flip: true)
    }

    static var expectedInitialTree: some View {
        Row {
            if true {
                Text("Text 1")
                Text("Text 2")

                Image(source: "icon")

                Column {
                    Text("Subtext 1")
                    Text("Subtext 2")
                }
            } else {
                Text("Label 1")
                Text("Label 2")

                Image(source: "logo")

                Column {
                    Text("Subtitle 1")
                    Text("Subtitle 2")
                }
            }
        }
    }

    static var updatedView: TestView {
        TestView(flip: false)
    }

    static var expectedUpdatedTree: some View {
        Row {
            if false {
                Text("Text 1")
                Text("Text 2")

                Image(source: "icon")

                Column {
                    Text("Subtext 1")
                    Text("Subtext 2")
                }
            } else {
                Text("Label 1")
                Text("Label 2")

                Image(source: "logo")

                Column {
                    Text("Subtitle 1")
                    Text("Subtitle 2")
                }
            }
        }
    }
}

/// Tests a conditional view with an empty `else` clause (remove `if` views).
struct EmptySecondRemoveFirstConditionalTestCase: BodyNodeTestCase {
    struct TestView: View, Equatable {
        var flip: Bool

        var body: some View {
            Column {
                if flip {
                    Text("Text 1")
                    Text("Text 2")

                    Row {
                        Image(source: "@banner-wide")
                    }
                } else {}
            }
        }
    }

    static var initialView: TestView {
        TestView(flip: true)
    }

    static var expectedInitialTree: some View {
        Column {
            if true {
                Text("Text 1")
                Text("Text 2")

                Row {
                    Image(source: "@banner-wide")
                }
            } else {}
        }
    }

    static var updatedView: TestView {
        TestView(flip: false)
    }

    static var expectedUpdatedTree: some View {
        Column {
            if false {
                Text("Text 1")
                Text("Text 2")

                Row {
                    Image(source: "@banner-wide")
                }
            } else {}
        }
    }
}

/// Tests a conditional view with an empty `else` clause (add `if` views).
struct EmptySecondAddFirstConditionalTestCase: BodyNodeTestCase {
    struct TestView: View, Equatable {
        var flip: Bool

        var body: some View {
            Column {
                if flip {
                    Text("Text 1")
                    Text("Text 2")

                    Row {
                        Image(source: "@banner-wide")
                    }
                } else {}
            }
        }
    }

    static var initialView: TestView {
        TestView(flip: false)
    }

    static var expectedInitialTree: some View {
        Column {
            if false {
                Text("Text 1")
                Text("Text 2")

                Row {
                    Image(source: "@banner-wide")
                }
            } else {}
        }
    }

    static var updatedView: TestView {
        TestView(flip: true)
    }

    static var expectedUpdatedTree: some View {
        Column {
            if true {
                Text("Text 1")
                Text("Text 2")

                Row {
                    Image(source: "@banner-wide")
                }
            } else {}
        }
    }
}

/// Tests a conditional view with an empty `if` clause (remove `else` views).
struct EmptyFirstRemoveSecondConditionalTestCase: BodyNodeTestCase {
    struct TestView: View, Equatable {
        var flip: Bool

        var body: some View {
            Column {
                if flip {} else {
                    Text("Text 1")
                    Text("Text 2")

                    Row {
                        Image(source: "@banner-wide")
                    }
                }
            }
        }
    }

    static var initialView: TestView {
        TestView(flip: false)
    }

    static var expectedInitialTree: some View {
        Column {
            if false {} else {
                Text("Text 1")
                Text("Text 2")

                Row {
                    Image(source: "@banner-wide")
                }
            }
        }
    }

    static var updatedView: TestView {
        TestView(flip: true)
    }

    static var expectedUpdatedTree: some View {
        Column {
            if true {} else {
                Text("Text 1")
                Text("Text 2")

                Row {
                    Image(source: "@banner-wide")
                }
            }
        }
    }
}

/// Tests a conditional view with an empty `if` clause (add `else` views).
struct EmptyFirstAddSecondConditionalTestCase: BodyNodeTestCase {
    struct TestView: View, Equatable {
        var flip: Bool

        var body: some View {
            Column {
                if flip {} else {
                    Text("Text 1")
                    Text("Text 2")

                    Row {
                        Image(source: "@banner-wide")
                    }
                }
            }
        }
    }

    static var initialView: TestView {
        TestView(flip: true)
    }

    static var expectedInitialTree: some View {
        Column {
            if true {} else {
                Text("Text 1")
                Text("Text 2")

                Row {
                    Image(source: "@banner-wide")
                }
            }
        }
    }

    static var updatedView: TestView {
        TestView(flip: true)
    }

    static var expectedUpdatedTree: some View {
        Column {
            if true {} else {
                Text("Text 1")
                Text("Text 2")

                Row {
                    Image(source: "@banner-wide")
                }
            }
        }
    }
}

/// Tests a conditional with an optional in the conditional cases that gets removed.
struct ConditionalRemoveOptionalTestCase: BodyNodeTestCase {
    struct TestView: View, Equatable {
        var flip: Bool
        let constant = false

        var body: some View {
            Column {
                if flip {
                    Text("Text 1")

                    if constant {
                        Text("Text 1.2")
                        Text("Text 1.3")
                        Text("Text 1.4")
                    }

                    Text("Text 2")
                } else {
                    Row {
                        Image(source: "user-icon")
                        Text("Log in")
                    }
                }
            }
        }
    }

    static var initialView: TestView {
        TestView(flip: true)
    }

    static var expectedInitialTree: some View {
        Column {
            if true {
                Text("Text 1")

                if false {
                    Text("Text 1.2")
                    Text("Text 1.3")
                    Text("Text 1.4")
                }

                Text("Text 2")
            } else {
                Row {
                    Image(source: "user-icon")
                    Text("Log in")
                }
            }
        }
    }

    static var updatedView: TestView {
        TestView(flip: false)
    }

    static  var expectedUpdatedTree: some View {
        Column {
            if false {
                Text("Text 1")

                if false {
                    Text("Text 1.2")
                    Text("Text 1.3")
                    Text("Text 1.4")
                }

                Text("Text 2")
            } else {
                Row {
                    Image(source: "user-icon")
                    Text("Log in")
                }
            }
        }
    }
}

/// Tests a conditional with an optional in the conditional cases that gets added.
struct ConditionalAddOptionalTestCase: BodyNodeTestCase {
    struct TestView: View, Equatable {
        var flip: Bool
        let constant = false

        var body: some View {
            Column {
                if flip {
                    Text("Text 1")

                    if constant {
                        Text("Text 1.2")
                        Text("Text 1.3")
                        Text("Text 1.4")
                    }

                    Text("Text 2")
                } else {
                    Row {
                        Image(source: "user-icon")
                        Text("Log in")
                    }
                }
            }
        }
    }

    static var initialView: TestView {
        TestView(flip: false)
    }

    static var expectedInitialTree: some View {
        Column {
            if false {
                Text("Text 1")

                if false {
                    Text("Text 1.2")
                    Text("Text 1.3")
                    Text("Text 1.4")
                }

                Text("Text 2")
            } else {
                Row {
                    Image(source: "user-icon")
                    Text("Log in")
                }
            }
        }
    }

    static var updatedView: TestView {
        TestView(flip: true)
    }

    static  var expectedUpdatedTree: some View {
        Column {
            if true {
                Text("Text 1")

                if false {
                    Text("Text 1.2")
                    Text("Text 1.3")
                    Text("Text 1.4")
                }

                Text("Text 2")
            } else {
                Row {
                    Image(source: "user-icon")
                    Text("Log in")
                }
            }
        }
    }
}

/// Tests an "unbalanced" conditional where there are more views on one side
/// than there are on the other, with entirely different types.
struct UnbalancedConditionalTestCase: BodyNodeTestCase {
    struct TestView: View, Equatable {
        var flip: Bool

        var body: some View {
            Row {
                if flip {
                    Text("Text 1")
                    Text("Text 2")
                    Text("Text 3")
                } else {
                    Image(source: "pic1.webp")
                    Image(source: "pic2.webp")

                    Column {
                        Text("Text 2.1")
                        Text("Text 2.2")
                    }
                }
            }
        }
    }

    static var initialView: TestView {
        TestView(flip: false)
    }

    static var expectedInitialTree: some View {
        Row {
            if false {
                Text("Text 1")
                Text("Text 2")
                Text("Text 3")
            } else {
                Image(source: "pic1.webp")
                Image(source: "pic2.webp")

                Column {
                    Text("Text 2.1")
                    Text("Text 2.2")
                }
            }
        }
    }

    static var updatedView: TestView {
        TestView(flip: true)
    }

    static var expectedUpdatedTree: some View {
        Row {
            if true {
                Text("Text 1")
                Text("Text 2")
                Text("Text 3")
            } else {
                Image(source: "pic1.webp")
                Image(source: "pic2.webp")

                Column {
                    Text("Text 2.1")
                    Text("Text 2.2")
                }
            }
        }
    }
}

/// Tests nesting optionals: insert views in the middle of a
/// tuple view, itself inside an optional.
struct NestedOptionalInsertionTestCase: BodyNodeTestCase {
    struct TestView: View, Equatable {
        var fillColumn = true
        var full: Bool

        var body: some View {
            Column {
                if fillColumn {
                    Text("Text 1")
                    Text("Text 2")

                    if full {
                        Text("Text 3")
                        Text("Text 4")
                    }

                    Text("Last text")
                }
            }
        }
    }

    static var initialView: TestView {
        TestView(full: false)
    }

    static var expectedInitialTree: some View {
        Column {
            if true {
                Text("Text 1")
                Text("Text 2")

                if false {
                    Text("Text 3")
                    Text("Text 4")
                }

                Text("Last text")
            }
        }
    }

    static var updatedView: TestView {
        TestView(full: true)
    }

    static var expectedUpdatedTree: some View {
        Column {
            if true {
                Text("Text 1")
                Text("Text 2")

                if true {
                    Text("Text 3")
                    Text("Text 4")
                }

                Text("Last text")
            }
        }
    }
}

/// Tests nesting optionals: insert views in the middle of a
/// tuple view, itself inside an optional.
struct NestedOptionalUpdateTestCase: BodyNodeTestCase {
    struct TestView: View, Equatable {
        var fillColumn = true
        var full: Bool

        var body: some View {
            Column {
                if fillColumn {
                    Text("Text 1")
                    Text("Text 2")

                    Text(full ? "Full Text 3" : "Text 3")
                    Text(full ? "Full Text 4" : "Text 4")

                    Text("Last text")
                }
            }
        }
    }

    static var initialView: TestView {
        TestView(full: false)
    }

    static var expectedInitialTree: some View {
        Column {
            if true {
                Text("Text 1")
                Text("Text 2")

                Text("Text 3")
                Text("Text 4")

                Text("Last text")
            }
        }
    }

    static var updatedView: TestView {
        TestView(full: true)
    }

    static var expectedUpdatedTree: some View {
        Column {
            if true {
                Text("Text 1")
                Text("Text 2")

                Text("Full Text 3")
                Text("Full Text 4")

                Text("Last text")
            }
        }
    }
}

/// Tests nesting optionals: removed views in the middle of a
/// tuple view, itself inside an optional.
struct NestedOptionalRemovalTestCase: BodyNodeTestCase {
    struct TestView: View, Equatable {
        var fillColumn = true
        var full: Bool

        var body: some View {
            Column {
                if fillColumn {
                    Text("Text 1")
                    Text("Text 2")

                    if full {
                        Text("Text 3")
                        Text("Text 4")
                    }

                    Text("Last text")
                }
            }
        }
    }

    static var initialView: TestView {
        TestView(full: true)
    }

    static var expectedInitialTree: some View {
        Column {
            if true {
                Text("Text 1")
                Text("Text 2")

                if true {
                    Text("Text 3")
                    Text("Text 4")
                }

                Text("Last text")
            }
        }
    }

    static var updatedView: TestView {
        TestView(full: false)
    }

    static var expectedUpdatedTree: some View {
        Column {
            if true {
                Text("Text 1")
                Text("Text 2")

                if false {
                    Text("Text 3")
                    Text("Text 4")
                }

                Text("Last text")
            }
        }
    }
}

/// Tests insertions, removals and updates on large tuple views to test
/// the offset mechanism on tuple views, optionals and conditionals.
/// TODO: add if / elses somewhere to test conditionals once they are implemented
struct OffsetsTestCase: BodyNodeTestCase {
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
struct UpdateTestCase: BodyNodeTestCase {
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
struct NoInputTestCase: BodyNodeTestCase {
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
struct OptionalUpdateTestCase: BodyNodeTestCase {
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

/// Test case for a view that has an optional part in its body that does not get updated.
struct OptionalUnchangedTestCase: BodyNodeTestCase {
    struct TestView: View, Equatable {
        var hasImageRow: Bool

        var body: some View {
            Column {
                if hasImageRow {
                    Row {
                        Image(source: "http://perdu.com/picture7-887.jpg")
                    }
                }
                if !hasImageRow {
                    Text("Image unavailable")
                }
                Column {}
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
                    Image(source: "http://perdu.com/picture7-887.jpg")
                }
            }
            if false {
                Text("Image unavailable")
            }
            Column {}
        }
    }

    static var updatedView: TestView {
        TestView(hasImageRow: true)
    }

    static var expectedUpdatedTree: some View {
        Column {
            if true {
                Row {
                    Image(source: "http://perdu.com/picture7-887.jpg")
                }
            }
            if false {
                Text("Image unavailable")
            }
            Column {}
        }
    }
}

/// Test case for a view that has an optional part in its body that gets inserted.
struct OptionalInsertionTestCase: BodyNodeTestCase {
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
struct OptionalRemovalTestCase: BodyNodeTestCase {
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
class BodyNodeSpecs: QuickSpec {
    override func spec() {
        for testCase in cases {
            describe("body node for \(testCase)") {
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
                    node.mountedElements[0].children!.expectToBe(expectedNode)
                }
            }
        }
    }
}

protocol BodyNodeTestCase {
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

extension BodyNodeTestCase {
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
        let description = "mounted views count of \(self.body.elementType) is different (\(self.listMountedViews()) VS. \(other.listMountedViews()))"
        expect(self.mountedElements.count).to(equal(other.mountedElements.count), description: description)

        for (n, (lhs, rhs)) in zip(self.mountedElements, other.mountedElements).enumerated() {
            lhs.expectToBe(rhs, position: n, bodyType: self.body.elementType)
        }
    }

    func listMountedViews() -> String {
        return "[\(self.mountedElements.map {$0.description}.joined(separator: ", "))]"
    }
}

extension AnyElement {
    /// Runs assertions to check that this view is equal to the given one.
    func expectToBe(_ other: AnyElement, propertyName: String) {
        // First compare view type
        if self.elementType != other.elementType {
            XCTFail("when comparing \(propertyName), view has a different type: got \(self.elementType) and \(other.elementType)")
        } else {
            // Then compare field by field
            if !self.equalsClosure(self.element, other) {
                XCTFail("when comparing \(propertyName), \(self.elementType) is different")
            }
        }
    }
}

extension MountedElement{
    /// Runs assertions to check that this mounted element is equal to the given one.
    func expectToBe(_ other: MountedElement, position: Int, bodyType: Any.Type) {
        // Check that the element is equal
        self.element.expectToBe(other.element, propertyName: "#\(position) MountedElement's view of body node \(bodyType)")

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
