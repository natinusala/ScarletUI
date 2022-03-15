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
from typing import List, Optional
from random import choice, randint, choices

# Use `swift test -Xswiftc -D -Xswiftc ENABLE_FUZZER -Xswiftc -suppress-warnings` to run the fuzzer after running this Python script

output = Path("Tests") / "ScarletUICoreTests" / "BodyNodeFuzzerTests"
count = 1000  # how many tests to generate?
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
    def make(ifs: bool, empty: bool, view: "TestView", depth: int) -> "BodyNode":
        # Leaf views
        kinds = [
            (Text, 20),
            (Image, 20),
            (NestedView, 10),
        ]

        # Everything that increases depth
        if depth < maxdepth:
            kinds += [
                (Column, 10),
                (Row, 10),
            ]

            # Only add if structures if allowed
            if ifs:
                kinds += [
                    (If, 10),
                    (IfElse, 10),
                    (IfElseIf, 15),
                    (IfElseIfElse, 15),
                ]

        # Empty
        if empty:
            kinds += [(Empty, 1)]

        kind = choices(
            [kind[0] for kind in kinds], weights=[kind[1] for kind in kinds], k=1
        )[0]

        return kind(view=view, depth=depth)


class Empty(BodyNode):
    def __init__(self, view: "TestView", depth: int):
        self.view = view

    def definition(self) -> list:
        return []

    def expected(self) -> list:
        return []


class Column(BodyNode):
    def __init__(self, view: "TestView", depth: int):
        self.view = view

        self.nodes = [
            BodyNode.make(ifs=True, empty=True, view=view, depth=depth + 1)
            for node in range(0, randint(0, 10))
        ]

    def definition(self) -> list:
        return indent(
            [
                "Column {",
                *chain(*[node.definition() for node in self.nodes]),
                "}",
            ],
        )

    def expected(self) -> list:
        return indent(
            [
                "Column {",
                *chain(*[node.expected() for node in self.nodes]),
                "}",
            ],
        )


class Row(BodyNode):
    def __init__(self, view: "TestView", depth: int):
        self.view = view

        self.nodes = [
            BodyNode.make(ifs=True, empty=True, view=view, depth=depth + 1)
            for node in range(0, randint(0, 10))
        ]

    def definition(self) -> list:
        return indent(
            [
                "Row {",
                *chain(*[node.definition() for node in self.nodes]),
                "}",
            ],
        )

    def expected(self) -> list:
        return indent(
            [
                "Row {",
                *chain(*[node.expected() for node in self.nodes]),
                "}",
            ],
        )


class If(BodyNode):
    def __init__(self, view: "TestView", depth: int):
        self.view = view
        self.flip = view.pick_flip()
        self.node = BodyNode.make(ifs=True, empty=True, view=view, depth=depth + 1)

    def definition(self) -> list:
        return indent(
            [
                f"if {self.flip.name} {{",
                *self.node.definition(),
                "}",
            ]
        )

    def expected(self) -> list:
        return indent(
            [
                f"if {self.flip.swiftValue} {{",
                *self.node.expected(),
                "}",
            ]
        )


class IfElse(BodyNode):
    def __init__(self, view: "TestView", depth: int):
        self.view = view
        self.flip = view.pick_flip()
        self.node_if = BodyNode.make(ifs=True, empty=True, view=view, depth=depth + 1)
        self.node_else = BodyNode.make(ifs=True, empty=True, view=view, depth=depth + 1)

    def definition(self) -> list:
        return indent(
            [
                f"if {self.flip.name} {{",
                *self.node_if.definition(),
                "} else {",
                *self.node_else.definition(),
                "}",
            ]
        )

    def expected(self) -> list:
        return indent(
            [
                f"if {self.flip.swiftValue} {{",
                *self.node_if.expected(),
                "} else {",
                *self.node_else.expected(),
                "}",
            ]
        )


class IfElseIf(BodyNode):
    def __init__(self, view: "TestView", depth: int):
        self.view = view
        self.flip = view.pick_flip()
        self.node_if = BodyNode.make(ifs=True, empty=True, view=view, depth=depth + 1)

        self.elseifs = [
            (
                BodyNode.make(ifs=True, empty=True, view=view, depth=depth + 1),
                view.pick_flip(),
            )
            for _ in range(0, randint(2, 8))
        ]

    def gen_elseifs_definition(self) -> list:
        res = []
        for elseif, flip in self.elseifs:
            res += [f"}} else if {flip.name} {{"]
            res += elseif.definition()
        return res

    def definition(self) -> list:
        return indent(
            [
                f"if {self.flip.name} {{",
                *self.node_if.definition(),
                *self.gen_elseifs_definition(),
                "}",
            ]
        )

    def gen_elseifs_expected(self) -> list:
        res = []
        for elseif, flip in self.elseifs:
            res += [f"}} else if {flip.swiftValue} {{"]
            res += elseif.expected()
        return res

    def expected(self) -> list:
        return indent(
            [
                f"if {self.flip.swiftValue} {{",
                *self.node_if.expected(),
                *self.gen_elseifs_expected(),
                "}",
            ]
        )


class IfElseIfElse(BodyNode):
    def __init__(self, view: "TestView", depth: int):
        self.view = view
        self.flip = view.pick_flip()
        self.node_if = BodyNode.make(ifs=True, empty=True, view=view, depth=depth + 1)
        self.node_else = BodyNode.make(ifs=True, empty=True, view=view, depth=depth + 1)

        self.elseifs = [
            (
                BodyNode.make(ifs=True, empty=True, view=view, depth=depth + 1),
                view.pick_flip(),
            )
            for _ in range(0, randint(2, 8))
        ]

    def gen_elseifs_definition(self) -> list:
        res = []
        for elseif, flip in self.elseifs:
            res += [f"}} else if {self.flip.name} {{"]
            res += elseif.definition()
        return res

    def definition(self) -> list:
        return indent(
            [
                f"if {self.flip.name} {{",
                *self.node_if.definition(),
                *self.gen_elseifs_definition(),
                "} else {",
                *self.node_else.definition(),
                "}",
            ]
        )

    def gen_elseifs_expected(self) -> list:
        res = []
        for elseif, flip in self.elseifs:
            res += [f"}} else if {self.flip.swiftValue} {{"]
            res += elseif.expected()
        return res

    def expected(self) -> list:
        return indent(
            [
                f"if {self.flip.swiftValue} {{",
                *self.node_if.expected(),
                *self.gen_elseifs_expected(),
                "} else {",
                *self.node_else.expected(),
                "}",
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

    def gen_text_definition(self) -> str:
        if hasattr(self, "text"):
            return f'"{self.text}"'
        else:
            return f'"{self.variable.name}=\({self.variable.name})"'

    def gen_text_expected(self) -> str:
        if hasattr(self, "text"):
            return f'"{self.text}"'
        else:
            return f'"{self.variable.name}={self.variable.value}"'


class Text(BodyNode):
    def __init__(self, view: "TestView", depth: int):
        self.view = view
        self.text = TextText(view=view)

    def definition(self) -> list:
        return indent([f"Text({self.text.gen_text_definition()})"])

    def expected(self) -> list:
        return indent([f"Text({self.text.gen_text_expected()})"])


class ImageSource:
    def __init__(self, view: "TestView"):
        self.view = view

        # Image can be a variable or a literal
        if coin_toss():
            self.source = f"https://pictures.com/{random_word()}.jpg"
        else:
            self.variable = view.pick_variable()

    def gen_source_definition(self) -> str:
        if hasattr(self, "source"):
            return self.source
        else:
            return f"https://pictures.com/picture\({self.variable.name}).jpg"

    def gen_source_expected(self) -> str:
        if hasattr(self, "source"):
            return self.source
        else:
            return f"https://pictures.com/picture{self.variable.value}.jpg"


class Image(BodyNode):
    def __init__(self, view: "TestView", depth: int):
        self.view = view
        self.source = ImageSource(view=view)

    def definition(self) -> list:
        return indent([f'Image(source: "{self.source.gen_source_definition()}")'])

    def expected(self) -> list:
        return indent([f'Image(source: "{self.source.gen_source_expected()}")'])


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

    def flip_definition(self, idx) -> str:
        if isinstance(self.nestedflips[idx], str):
            return self.nestedflips[idx]
        else:
            return self.nestedflips[idx].name

    def variable_definition(self, idx) -> str:
        if isinstance(self.nestedvariables[idx], str):
            return self.nestedvariables[idx]
        else:
            return self.nestedvariables[idx].name

    def flip_expected(self, idx) -> str:
        if isinstance(self.nestedflips[idx], str):
            return self.nestedflips[idx]
        else:
            return self.nestedflips[idx].swiftValue

    def variable_expected(self, idx) -> str:
        if isinstance(self.nestedvariables[idx], str):
            return self.nestedvariables[idx]
        else:
            return self.nestedvariables[idx].value

    def gen_flips_definition(self) -> list:
        return [
            f"{flip.name}: {self.flip_definition(idx)}"
            for (idx, flip) in enumerate(self.nestedview.flips)
        ]

    def gen_variables_definition(self) -> list:
        return [
            f"{variable.name}: {self.variable_definition(idx)}"
            for (idx, variable) in enumerate(self.nestedview.variables)
        ]

    def gen_args_definition(self) -> str:
        return ", ".join(
            [
                *self.gen_flips_definition(),
                *self.gen_variables_definition(),
            ]
        )

    def definition(self) -> list:
        return indent([f"{self.nestedview.name}({self.gen_args_definition()})"])

    def gen_flips_expected(self) -> list:
        return [
            f"{flip.name}: {self.flip_expected(idx)}"
            for (idx, flip) in enumerate(self.nestedview.flips)
        ]

    def gen_variables_expected(self) -> list:
        return [
            f"{variable.name}: {self.variable_expected(idx)}"
            for (idx, variable) in enumerate(self.nestedview.variables)
        ]

    def gen_args_expected(self) -> str:
        return ", ".join(
            [
                *self.gen_flips_expected(),
                *self.gen_variables_expected(),
            ]
        )

    def expected(self) -> list:
        return indent([f"{self.nestedview.name}({self.gen_args_expected()})"])


class ViewBody:
    def __init__(self, view: "TestView"):
        self.view = view

        # TODO: change ifs to True here once body has ViewBuilder support
        self.node = BodyNode.make(ifs=False, empty=False, view=view, depth=0)

    def definition(self) -> list:
        return [
            "        var body: some View {",
            *[f"        {line}" for line in self.node.definition()],
            "        }",
        ]

    def expected(self) -> list:
        return self.node.expected()


@dataclass
class Variable:
    name: str
    value: Optional[int] = None


@dataclass
class Flip:
    name: str
    value: Optional[bool] = None

    @property
    def swiftValue(self) -> str:
        return "true" if self.value else "false"


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

    def populate_input(self):
        for flip in self.flips:
            flip.value = choice([True, False])

        for variable in self.variables:
            variable.value = randint(0, 250)

    def gen_constructor(self) -> str:
        params = [f"{flip.name}: {str(flip.value).lower()}" for flip in self.flips]
        params += [f"{variable.name}: {variable.value}" for variable in self.variables]

        return f"{self.name}({', '.join(params)})"

    def gen_expected(self) -> list:
        return self.body.expected()

    def gen_flips(self) -> list:
        return [f"        let {flip.name}: Bool" for flip in self.flips]

    def gen_variables(self) -> list:
        return [f"        let {variable.name}: Int" for variable in self.variables]

    def pick_variable(self) -> Variable:
        # Either pick an existing variable or create one
        # If there is no variable, always create a new one
        # If we already created enough variables, always pick one
        if (not self.variables or coin_toss()) and len(self.variables) < maxvars:
            idx = len(self.variables)
            variable = Variable(name="variable" + str(idx))
            self.variables += [variable]
            return variable
        else:
            return choice(self.variables)

    def pick_flip(self) -> Flip:
        # Either pick an existing flip or create one
        # If there is no flip, always create a new one
        # If we already created enough flips, always pick one
        if (not self.flips or coin_toss()) and len(self.flips) < maxflips:
            idx = len(self.flips)
            flip = Flip(name="flip" + str(idx))
            self.flips += [flip]
            return flip
        else:
            return choice(self.flips)


class TestCase:
    def __init__(self, name: str):
        self.views = []
        self.name = name

        # Make TestView0
        self.root_testview = self.new_view()

    def definition(self) -> list:
        return [
            f"struct {self.name}: BodyNodeTestCase {{",
            *self.gen_views_definition(),
            "",
            *self.gen_initial(),
            "",
            *self.gen_updated(),
            "}",
        ]

    def gen_initial(self) -> list:
        # Give random values to all flips and variables
        self.root_testview.populate_input()

        return [
            f"    static var initialView: {self.root_testview.name} {{",
            f"        {self.root_testview.gen_constructor()}",
            "    }",
            "",
            "    static var expectedInitialTree: some View {",
            "    " + "\n".join(self.root_testview.gen_expected()),
            "    }",
        ]

    def gen_updated(self) -> list:
        # Give random values to all flips and variables
        self.root_testview.populate_input()

        return [
            f"    static var updatedView: {self.root_testview.name} {{",
            f"        {self.root_testview.gen_constructor()}",
            "    }",
            "",
            "    static var expectedUpdatedTree: some View {",
            "    " + "\n".join(self.root_testview.gen_expected()),
            "    }",
        ]

    def gen_views_definition(self) -> list:
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

    lines = [
        "// Generated by bodynode_fuzzer.py, do not edit",
        "",
        "import Foundation",
        "import XCTest",
        "import Quick",
        "import Nimble",
        "@testable import ScarletUICore",
        "",
    ]

    lines += TestCase(name).definition()

    with open(testcase, "w") as file:
        file.write("\n".join(lines))

# Generate the specs file
specs = output / "BodyNodeFuzzerTests.swift"


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
    "fileprivate let specs: [BodyNodeTestCaseSpecs.Type] = [",
    *gen_cases(),
    "]",
    "",
    "class BodyNodeFuzzerTests: QuickSpec {",
    "    override func spec() {",
    "        for spec in specs { spec.spec() }",
    "    }",
    "}",
]

with open(specs, "w") as file:
    file.write("\n".join(lines))
