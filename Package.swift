// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ScarletUI",
    products: [
        .library(
            name: "ScarletUICore",
            targets: ["ScarletUICore"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/Quick/Quick.git", .upToNextMajor(from: "4.0.0")),
        .package(url: "https://github.com/Quick/Nimble.git", .upToNextMajor(from: "9.2.1")),
    ],
    targets: [
        .target(
            name: "ScarletUICore",
            dependencies: []
        ),
        .testTarget(
            name: "ScarletUICoreTests",
            dependencies: ["ScarletUICore", "Nimble", "Quick"]
        ),
    ]
)
