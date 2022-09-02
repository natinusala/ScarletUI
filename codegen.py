import subprocess


def run(*cmd):
    print(f"Running {' '.join(cmd)}")
    subprocess.run(cmd)


for i in range(1, 10):
    run(
        "gyb",
        f"-DIDX={i}",
        "-o",
        f"Sources/ScarletCore/ElementNodes/StaticElementNodes/StaticElementNode{i}.swift",
        "--line-directive",
        "",
        "Sources/ScarletCore/ElementNodes/StaticElementNode.gyb",
    )
