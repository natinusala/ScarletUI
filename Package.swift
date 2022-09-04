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
        ),
    ],
    dependencies: [
        // Core dependencies
        .package(url: "https://github.com/onevcat/Rainbow.git", .upToNextMajor(from: "4.0.0")),
        .package(url: "https://github.com/wickwirew/Runtime", .upToNextMajor(from: "2.2.4")),
        .package(url: "https://github.com/OpenCombine/OpenCombine.git", from: "0.13.0"),

        // Linux compat
        .package(url: "https://github.com/swift-server/swift-backtrace.git", .upToNextMajor(from: "1.3.1")),

        // Testing
        .package(url: "https://github.com/Quick/Quick.git", .upToNextMajor(from: "4.0.0")),
        .package(url: "https://github.com/Quick/Nimble.git", .upToNextMajor(from: "9.2.1")),
        .package(url: "https://github.com/natinusala/mockolo-linux", branch: "fb627cfd1b1f8058ab5cae1ced30c2419cc6a0eb")
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
                "Glad",
                "Skia",
                .product(name: "Backtrace", package: "swift-backtrace"),
            ]
        ),
        // ScarletCore: core library containing the DSL and graph / state management code
        .target(
            name: "ScarletCore",
            dependencies: [
                "Rainbow",
                "Runtime",
                "OpenCombine",
            ],
            exclude: [
                "ElementNodes/StaticElementNode.gyb",
                "Views/TupleView.gyb",
            ]
        ),
        // ScarletNative: native code companion to ScarletUI
        .target(
            name: "ScarletNative",
            dependencies: ["GLFW", "CGlad"]
        ),
        // ScarletUIDemo: simple ScarletUI demo app
        .executableTarget(
            name: "ScarletUIDemo",
            dependencies: ["ScarletUI"]
        ),
        // Test targets
        .testTarget(
            name: "ScarletCoreUnitTests",
            dependencies: [
                "ScarletCore",
                "Quick",
                "Nimble",
                .product(name: "Backtrace", package: "swift-backtrace"),
            ],
            plugins: [
                .plugin(name: "MockoloPlugin", package: "mockolo"),
            ]
        ),
        .testTarget(
            name: "ScarletCoreIntegrationTests",
            dependencies: [
                "ScarletCore",
                "Quick",
                "Nimble",
                .product(name: "Backtrace", package: "swift-backtrace"),
            ],
            plugins: [
                .plugin(name: "MockoloPlugin", package: "mockolo"),
            ]
        ),
        // Embedded native libraries
        .target(
            name: "CYoga",
            path: "External/CYoga",
            exclude: [
                "BUCK",
                "CMakeLists.txt",
                "CODE_OF_CONDUCT.md",
                "CONTRIBUTING.md",
                "LICENSE",
                "LICENSE-examples",
                "README.md",
                "Yoga.podspec",
                "YogaKit",
                "YogaKit.podspec",
                "android",
                "benchmark",
                "build.gradle",
                "csharp",
                "enums.py",
                "gentest",
                "gradle",
                "gradle.properties",
                "gradlew",
                "gradlew.bat",
                "java",
                "javascript",
                "lib",
                "mode",
                "scripts",
                "settings.gradle",
                "tests",
                "testutil",
                "third-party(Yoga).xcconfig",
                "tools",
                "util",
                "website",
                "yogacore",
            ],
            sources: ["yoga"],
            publicHeadersPath: ".",
            linkerSettings: [.linkedLibrary("m")]
        ),
        .target(
            name: "Yoga",
            dependencies: ["CYoga"],
            path: "External/Yoga"
        ),
        .systemLibrary(name: "GLFW", path: "External/GLFW", pkgConfig: "glfw3"),
        .systemLibrary(name: "Skia", path: "External/Skia", pkgConfig: "skia_loftwing"),
        .target(
            name: "CGlad",
            path: "External/CGlad"
        ),
        .target(
            name: "Glad",
            dependencies: ["CGlad"],
            path: "External/Glad"
        ),
    ]
)
