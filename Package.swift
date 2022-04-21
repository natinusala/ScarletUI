// swift-tools-version: 5.6

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

import PackageDescription

let package = Package(
    name: "ScarletUI",
    products: [
        .library(
            name: "ScarletUI",
            targets: ["ScarletUI"]
        ),
        .executable(
            name: "ScarletUIDemo",
            targets: ["ScarletUIDemo"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/Quick/Quick.git", .upToNextMajor(from: "4.0.0")),
        .package(url: "https://github.com/Quick/Nimble.git", .upToNextMajor(from: "9.2.1")),
        .package(url: "https://github.com/swift-server/swift-backtrace.git", .upToNextMajor(from: "1.3.1")),
        .package(url: "https://github.com/onevcat/Rainbow.git", .upToNextMajor(from: "4.0.0")),
    ],
    targets: [
        // ScarletUI: contains scenes, views, modifiers as well as the actual runtime
        // on top of ScarletCore - also exposes ScarletCore for the DSL and custom views
        .target(
            name: "ScarletUI",
            dependencies: [
                "ScarletCore",
                "ScarletNative",
                "Yoga",
                "GLFW",
                "Skia",
                .product(name: "Backtrace", package: "swift-backtrace"),
            ]
        ),
        // ScarletCore: core library containing the DSL and graph / state management code
        .target(
            name: "ScarletCore",
            dependencies: ["Rainbow"]
        ),
        // ScarletNative: native code companion to ScarletUI
        .target(
            name: "ScarletNative",
            dependencies: []
        ),
        // ScarletUIDemo: simple ScarletUI demo app
        .executableTarget(
            name: "ScarletUIDemo",
            dependencies: ["ScarletUI"]
        ),
        // Test targets
        .testTarget(
            name: "ScarletCoreTests",
            dependencies: ["ScarletCore", "Nimble", "Quick", .product(name: "Backtrace", package: "swift-backtrace")]
        ),
        // Embedded native libraries
        .target(
            name: "CYoga",
            path: "External/CYoga",
            exclude: ["LICENSE"],
            linkerSettings: [.linkedLibrary("m")]
        ),
        .target(
            name: "Yoga",
            dependencies: ["CYoga"],
            path: "External/Yoga"
        ),
        .systemLibrary(name: "GLFW", path: "External/GLFW", pkgConfig: "glfw3"),
        .systemLibrary(name: "Skia", path: "External/Skia", pkgConfig: "skia_loftwing"),
    ]
)
