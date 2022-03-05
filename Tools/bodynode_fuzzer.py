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
from random import choice, randint, choices

# Use `swift test -Xswiftc -D -Xswiftc ENABLE_FUZZER` to run the fuzzer after running this Python script

output = Path("Tests") / "ScarletUICoreTests" / "BodyNodeFuzzerTests"
count = 10  # how many tests to generate?
maxdepth = 3  # maximum depth of generated views body TODO: randomize for each test case
maxflips = 5  # maximum number of flips inside each test view
maxvars = 5  # maximum number of variables inside each test view
maxviews = 1  # maximum number of test views each view can generate


def coin_toss() -> bool:
    return choice([True, False])


def random_word() -> str:
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
        kinds = [
            (Text, 20),
            (Image, 20),
            (NestedView, 10),
        ]

        if depth < maxdepth:
            kinds += [
                (Column, 10),
                (Row, 10),
                (If, 10),
                (IfElse, 10),
                (IfElseIf, 15),
                (IfElseIfElse, 15),
            ]

        if empty:
            kinds += [(Empty, 1)]

        kind = choices(
            [kind[0] for kind in kinds],
            weights=[kind[1] for kind in kinds],
            k=1
        )[0]

        return kind(view=view, depth=depth)


class Empty(BodyNode):
    def __init__(self, view: "TestView", depth: int):
        self.view = view

    def definition(self) -> list:
        return []


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
    def __init__(self, view: "TestView", depth: int):
        self.view = view
        self.flip = view.pick_flip()
        self.node = BodyNode.make(empty=True, view=view, depth=depth+1)

    def definition(self) -> list:
        return indent(
            [
                f"if {self.view.flips[self.flip]} {{",
                *self.node.definition(),
                "}",
            ]
        )


class IfElse(BodyNode):
    def __init__(self, view: "TestView", depth: int):
        self.view = view
        self.flip = view.pick_flip()
        self.node_if = BodyNode.make(empty=True, view=view, depth=depth+1)
        self.node_else = BodyNode.make(empty=True, view=view, depth=depth+1)

    def definition(self) -> list:
        return indent(
            [
                f"if {self.view.flips[self.flip]} {{",
                *self.node_if.definition(),
                "} else {",
                *self.node_else.definition(),
                "}"
            ]
        )


class IfElseIf(BodyNode):
    def __init__(self, view: "TestView", depth: int):
        self.view = view
        self.flip = view.pick_flip()
        self.node_if = BodyNode.make(empty=True, view=view, depth=depth+1)

        self.elseifs = [
            (BodyNode.make(empty=True, view=view, depth=depth+1), view.pick_flip())
            for _ in range(0, randint(2, 8))
        ]

    def gen_elseifs(self) -> list:
        res = []
        for elseif, flip in self.elseifs:
            res += [f"}} else if {self.view.flips[flip]} {{"]
            res += elseif.definition()
        return res

    def definition(self) -> list:
        return indent(
            [
                f"if {self.view.flips[self.flip]} {{",
                *self.node_if.definition(),
                *self.gen_elseifs(),
                "}",
            ]
        )


class IfElseIfElse(BodyNode):
    def __init__(self, view: "TestView", depth: int):
        self.view = view
        self.flip = view.pick_flip()
        self.node_if = BodyNode.make(empty=True, view=view, depth=depth+1)
        self.node_else = BodyNode.make(empty=True, view=view, depth=depth+1)

        self.elseifs = [
            (BodyNode.make(empty=True, view=view, depth=depth+1), view.pick_flip())
            for _ in range(0, randint(2, 8))
        ]

    def gen_elseifs(self) -> list:
        res = []
        for elseif, flip in self.elseifs:
            res += [f"}} else if {self.view.flips[flip]} {{"]
            res += elseif.definition()
        return res

    def definition(self) -> list:
        return indent(
            [
                f"if {self.view.flips[self.flip]} {{",
                *self.node_if.definition(),
                *self.gen_elseifs(),
                "} else {",
                *self.node_else.definition(),
                "}"
            ]
        )


class TextText:
    def __init__(self, view: "TestView"):
        self.view = view

        # Text can be a variable or a literal
        if coin_toss():
            self.text = random_word()
        else:
            self.variable = view.pick_variable()

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
        if coin_toss():
            self.source = f"https://pictures.com/{random_word()}.jpg"
        else:
            self.variable = view.pick_variable()

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
    def __init__(self, view: "TestView", depth: int):
        self.view = view
        self.nestedview = view.testcase.pick_view()

        self.nestedflips = []
        self.nestedvariables = []

        # Select values for every flip and variable: literals or existing flips and variables
        for _ in self.nestedview.flips:
            if coin_toss():
                self.nestedflips += [choice(["true", "false"])]
            else:
                self.nestedflips += [view.pick_flip()]

        for _ in self.nestedview.variables:
            if coin_toss():
                self.nestedvariables += [str(randint(0, 100))]
            else:
                self.nestedvariables += [view.pick_variable()]

    def flip_value(self, idx) -> str:
        if isinstance(self.nestedflips[idx], str):
            return self.nestedflips[idx]
        else:
            return self.view.flips[self.nestedflips[idx]]

    def variable_value(self, idx) -> str:
        if isinstance(self.nestedvariables[idx], str):
            return self.nestedvariables[idx]
        else:
            return self.view.variables[self.nestedvariables[idx]]

    def gen_flips(self) -> list:
        return [
            f"{flip}: {self.flip_value(idx)}"
            for (idx, flip) in enumerate(self.nestedview.flips)
        ]

    def gen_variables(self) -> list:
        return [
            f"{variable}: {self.variable_value(idx)}"
            for (idx, variable) in enumerate(self.nestedview.variables)
        ]

    def gen_args(self) -> str:
        return ", ".join(
            [
                *self.gen_flips(),
                *self.gen_variables(),
            ]
        )

    def definition(self) -> list:
        return indent([f'{self.nestedview.name}({self.gen_args()})'])


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
    def __init__(self, name: str, testcase: "TestCase"):
        self.name = name
        self.testcase = testcase
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

    def pick_variable(self) -> int:
        # Either pick an existing variable or create one
        # If there is no variable, always create a new one
        # If we already created enough variables, always pick one
        if (not self.variables or coin_toss()) and len(self.variables) < maxvars:
            idx = len(self.variables)
            self.variables += ["variable" + str(idx)]
            return idx
        else:
            return randint(0, len(self.variables) - 1)

    def pick_flip(self) -> int:
        # Either pick an existing flip or create one
        # If there is no flip, always create a new one
        # If we already created enough flips, always pick one
        if (not self.flips or coin_toss()) and len(self.flips) < maxflips:
            idx = len(self.flips)
            self.flips += ["flip" + str(idx)]
            return idx
        else:
            return randint(0, len(self.flips) - 1)


class TestCase:
    def __init__(self, name: str):
        self.views = []
        self.name = name

        # Make TestView0
        self.root_testview = self.new_view()

    def definition(self) -> list:
        return [
            f"struct {self.name}: BodyNodeTestCase {{",
            *self.gen_views(),
            "}",
        ]

    def gen_views(self) -> list:
        """Makes all views of this test case."""
        return chain(*[view.definition() for view in self.views])

    def new_view(self) -> TestView:
        view = TestView(name=f"TestView{randint(0, 100000)}", testcase=self)
        self.views.append(view)
        return view

    def pick_view(self) -> TestView:
        # Either pick an existing view or create one
        # If there is no view, always create a new one
        if (not self.views or coin_toss()) and len(self.views) < maxviews:
            return self.new_view()
        else:
            return choice(self.views)


# Generate every test
for test in range(0, count):
    name = f"BodyNodeFuzzerTest{test}"
    testcase = output / f"{name}.swift"
    testcase.parent.mkdir(parents=True, exist_ok=True)

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
