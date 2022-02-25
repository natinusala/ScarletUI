from pathlib import Path
from itertools import chain

newline = "\n"

def gen_properties(i: int) -> list:
    """Generate properties for the given tuple view index."""
    return [
        f"    let c{ci}: C{ci}" for ci in range(0, i)
    ]

def gen_viewcount(i: int) -> list:
    """Generate `viewCount` method for the given tuple view index."""
    return [
        "    static func viewsCount(view: Self) -> Int {",
        f"        return {i}",
        "    }"
    ]

def gen_makeviews(i: int) -> list:
    """Generate `makeViews` method for the given tuple view index."""
    def gen_operations() -> list:
        """Generate cXOperations variables."""
        return [
            f"        let c{ci}Operations = C{ci}.makeViews(view: view.c{ci}, previous: previous?.c{ci})"
            for ci in range(0, i)
        ]

    def gen_offsets() -> list:
        """Generate cXOffset variables"""
        def gen_previous() -> list:
            """Generate offsets for when there is a previous view."""
            return [
                f"            c{ci}Offset = C{ci-1}.viewsCount(view: previous.c{ci-1}) + c{ci-1}Offset"
                for ci in range(1, i)
            ]

        def gen_noprevious() -> list:
            """Generate offsets for when there is no previous view."""
            return [
                f"            c{ci}Offset = C{ci-1}.viewsCount(view: view.c{ci-1}) + c{ci-1}Offset"
                for ci in range(1, i)
            ]

        offsets = ["        let c0Offset: Int = 0"]

        offsets += [
            f"        let c{ci}Offset: Int"
            for ci in range(1, i)
        ]

        offsets += [
            "",
            "        if let previous = previous {",
            *gen_previous(),
            "        } else {",
            *gen_noprevious(),
            "        }"
        ]

        return offsets

    def gen_return() -> list:
        """Generates return statement."""
        result = "        return c0Operations"

        for ci in range(1, i):
            result += f".appendAndOffset(operations: c{ci}Operations, offset: c{ci}Offset)"

        return [result]

    return [
        "    static func makeViews(view: Self, previous: Self?) -> ViewOperations {",
        *gen_operations(),
        "",
        *gen_offsets(),
        "",
        *gen_return(),
        "    }"
    ]

def gen_equals(i: int) -> list:
    """Generate the `equals` method."""
    def gen_guards() -> list:
        guards = []

        for ci in range(0, i):
            guards += [
                f"        guard C{ci}.equals(lhs: lhs.c{ci}, rhs: rhs.c{ci}) else {{",
                "            return false",
                "        }"
            ]

        return guards
    return [
        "    static func equals(lhs: Self, rhs: Self) -> Bool {",
        *gen_guards(),
        "",
        "        return true",
        "    }"
    ]

# Where to write the generated file
output = Path("Sources") / "ScarletUICore" / "Generated" / "TupleView.swift"

# Size of the biggest TupleView to generate (from 2 to `tv_max`)
tv_max = 10

# Generate file content
lines = []

for i in range(2, tv_max + 1):
    # TupleViewX struct
    lines += [
        f"struct TupleView{i}<{', '.join([f'C{ci}' for ci in range(0, i)])}>: View where {', '.join([f'C{ci}: View' for ci in range(0, i)])} {{",
        "    typealias Body = Never",
        "",
        *gen_properties(i),
        "",
        *gen_makeviews(i),
        "",
        *gen_viewcount(i),
        "",
        *gen_equals(i),
        "}",
        "",
    ]

    # `ViewBuilder` extension
    lines += [
        "extension ViewBuilder {",
        f"    static func buildBlock<{', '.join([f'C{ci}: View' for ci in range(0, i)])}>({', '.join([f'_ c{ci}: C{ci}' for ci in range(0, i)])}) -> TupleView{i}<{', '.join([f'C{ci}' for ci in range(0, i)])}> {{",
        f"        return .init({', '.join([f'c{ci}: c{ci}' for ci in range(0, i)])})",
        "    }",
        "}",
        "",
    ]

# Write file
output.parent.mkdir(parents=True, exist_ok=True)
with open(output, "w") as file:
    file.write(newline.join(lines))

