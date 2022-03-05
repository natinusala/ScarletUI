"""
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
"""

from pathlib import Path
from dataclasses import dataclass
from itertools import chain
from typing import List
from random import choice, randint

# Use `swift test -Xswiftc -D -Xswiftc ENABLE_FUZZER` to run the fuzzer after running this Python script

output = Path("Tests") / "ScarletUICoreTests" / "BodyNodeFuzzerTests"
count = 10  # how many tests to generate?
maxdepth = 5  # maximum depth of generated views body


def coinToss() -> bool:
    return choice([True, False])


def randomWord() -> str:
    return choice(
        [
            "Apple",
            "Chocolate",
            "Pear",
            "Berry",
            "Phone",
            "Switch",
            "Emulator",
            "Beer",
            "Bear",
            "Cat",
            "Dog",
            "Doug",
            "Rabbit",
            "Lamp",
            "Desk",
            "Mouse",
        ]
    )


def indent(lines: list) -> list:
    indent = "    "
    return [f"{indent}{line}" for line in lines]


# Test case data model
class BodyNode:
    @staticmethod
    def make(empty: bool, view: "TestView", depth: int) -> "BodyNode":
        if depth == maxdepth:
            return Empty(view=view, depth=depth)

        kinds = [
            Column,
            Row,
            # If,
            # IfElse,
            # IfElseIf,
            # IfElseIfElse,
            Text,
            Image,
            # NestedView,
        ]

        if empty:
            kinds += [Empty]

        kind = choice(kinds)
        return kind(view=view, depth=depth)


class Empty(BodyNode):
    def __init__(self, view: "TestView", depth: int):
        self.view = view

    def definition(self) -> list:
        return [""]


class Column(BodyNode):
    def __init__(self, view: "TestView", depth: int):
        self.view = view

        self.nodes = [
            BodyNode.make(empty=True, view=view, depth=depth+1) for node in range(0, randint(0, 10))
        ]

    def definition(self) -> list:
        return indent(
            [
                "Column {",
                *chain(*[node.definition() for node in self.nodes]),
                "}",
            ],
        )


class Row(BodyNode):
    def __init__(self, view: "TestView", depth: int):
        self.view = view

        self.nodes = [
            BodyNode.make(empty=True, view=view, depth=depth+1) for node in range(0, randint(0, 10))
        ]

    def definition(self) -> list:
        return indent(
            [
                "Row {",
                *chain(*[node.definition() for node in self.nodes]),
                "}",
            ],
        )


class If(BodyNode):
    pass


class IfElse(BodyNode):
    pass


class IfElseIf(BodyNode):
    pass


class IfElseIfElse(BodyNode):
    pass


class TextText:
    def __init__(self, view: "TestView"):
        self.view = view

        # Text can be a variable or a literal
        if coinToss():
            self.text = randomWord()
        else:
            self.variable = view.pickVariable()

    def gen_text(self) -> str:
        if hasattr(self, "text"):
            return f'"{self.text}"'
        else:
            return f'"{self.variable}=\({self.view.variables[self.variable]})"'


class Text(BodyNode):
    def __init__(self, view: "TestView", depth: int):
        self.view = view
        self.text = TextText(view=view)

    def definition(self) -> list:
        return indent([f"Text({self.text.gen_text()})"])


class ImageSource:
    def __init__(self, view: "TestView"):
        self.view = view

        # Image can be a variable or a literal
        if coinToss():
            self.source = f"https://pictures.com/{randomWord()}.jpg"
        else:
            self.variable = view.pickVariable()

    def gen_source(self) -> str:
        if hasattr(self, "source"):
            return self.source
        else:
            return f"https://pictures.com/picture\({self.view.variables[self.variable]}).jpg"


class Image(BodyNode):
    def __init__(self, view: "TestView", depth: int):
        self.view = view
        self.source = ImageSource(view=view)

    def definition(self) -> list:
        return indent([f'Image(source: "{self.source.gen_source()}")'])


class NestedView(BodyNode):
    pass


class ViewBody:
    def __init__(self, view: "TestView"):
        self.view = view
        self.node = BodyNode.make(empty=False, view=view, depth=0)

    def definition(self) -> list:
        return [
            "        var body: some View {",
            *[f"        {line}" for line in self.node.definition()],
            "        }",
        ]


class TestView:
    def __init__(self, name: str):
        self.name = name
        self.flips = []
        self.variables = []

        # Generate body
        self.body = ViewBody(view=self)

    def definition(self) -> list:
        return [
            f"    struct {self.name}: View, Equatable {{",
            *self.gen_flips(),
            *self.gen_variables(),
            "",
            *self.body.definition(),
            "    }",
        ]

    def gen_flips(self) -> list:
        return [f"        let {flip}: Bool" for flip in self.flips]

    def gen_variables(self) -> list:
        return [f"        let {variable}: Int" for variable in self.variables]

    def pickVariable(self) -> int:
        # Either pick an existing variable or create one
        # # If there is no variable, always create a new one
        if not self.variables or coinToss():
            idx = len(self.variables)
            self.variables += ["variable" + str(idx)]
            return idx
        else:
            return randint(0, len(self.variables) - 1)


class TestCase:
    def __init__(self, name: str):
        self.views = []
        self.name = name

        # Always make at least one test view
        self.views.append(TestView(name=f"TestView0"))

    def definition(self) -> list:
        return [
            f"struct {self.name}: BodyNodeTestCase {{",
            *self.gen_views(),
            "}",
        ]

    def gen_views(self) -> list:
        """Makes all views of this test case."""
        return chain(*[view.definition() for view in self.views])


# Generate every test
for test in range(0, count):
    name = f"BodyNodeFuzzerTest{test}"
    testcase = output / f"{name}.swift"

    lines = TestCase(name).definition()

    with open(testcase, "w") as file:
        file.write("\n".join(lines))

# Generate the specs file
specs = output / "BodyNodeFuzzerTests.swift"

specs_func = """        for testCase in cases {
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
"""


def gen_cases() -> list:
    """Generates the `cases` variable."""
    return [f"    BodyNodeFuzzerTest{i}.self," for i in range(0, count)]


lines = [
    "// Generated by bodynode_fuzzer.py, do not edit",
    "",
    "import Foundation",
    "import XCTest",
    "import Quick",
    "import Nimble",
    "@testable import ScarletUICore",
    "",
    "fileprivate let cases: [BodyNodeTestCase.Type] = [",
    *gen_cases(),
    "]",
    "",
    "class BodyNodeFuzzerTests: QuickSpec {",
    "    override func spec() {",
    specs_func,
    "    }",
    "}",
]

with open(specs, "w") as file:
    file.write("\n".join(lines))
