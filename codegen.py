import subprocess


def run(*cmd):
    print(f"Running {' '.join(cmd)}")
    subprocess.run(cmd)


max = 10

# StaticComponentNode
for i in range(1, max):
    run(
        "gyb",
        f"-DIDX={i}",
        "-o",
        f"Sources/ScarletCore/ComponentNodes/StaticComponentNodes/StaticComponentNode{i}.swift",
        "--line-directive",
        "",
        "Sources/ScarletCore/ComponentNodes/StaticComponentNode.gyb",
    )

# TupleView
for i in range(2, max):  # TupleView1 does not exist
    run(
        "gyb",
        f"-DIDX={i}",
        "-o",
        f"Sources/ScarletCore/Views/TupleViews/TupleView{i}.swift",
        "--line-directive",
        "",
        "Sources/ScarletCore/Views/TupleView.gyb",
    )

# ViewAttributes
for i in range(1, max):
    run(
        "gyb",
        f"-DIDX={i}",
        "-o",
        f"Sources/ScarletCore/Views/ViewAttributes/ViewAttribute{i}.swift",
        "--line-directive",
        "",
        "Sources/ScarletCore/Views/ViewAttribute.gyb",
    )
