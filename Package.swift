// swift-tools-version: 5.7

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
        .library(
            name: "ScarletUITests",
            targets: ["ScarletUITests"]
        ),
        .executable(
            name: "ScarletUIDemo",
            targets: ["ScarletUIDemo"]
        ),
    ],
    dependencies: [
        // Core dependencies
        .package(url: "https://github.com/wickwirew/Runtime.git", .upToNextMajor(from: "2.2.4")),
        .package(url: "https://github.com/OpenCombine/OpenCombine.git", .upToNextMajor(from: "0.13.0")),
        .package(url: "https://github.com/apple/swift-argument-parser.git", .upToNextMajor(from: "1.2.0")),

        // Logging
        .package(url: "https://github.com/vapor/console-kit.git", .upToNextMajor(from: "4.5.0")),
        .package(url: "https://github.com/natinusala/swift-cutelog.git", .upToNextMajor(from: "1.0.0")),

        // Utils
        .package(url: "https://github.com/davdroman/swift-builders.git", .upToNextMajor(from: "0.3.1")),

        // Linux compat
        .package(url: "https://github.com/natinusala/swift-backtrace.git", .upToNextMajor(from: "1.0.0")),
        .package(url: "https://github.com/JohnSundell/ShellOut", .upToNextMajor(from: "2.3.0")),

        // Documentation
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0"),

        // Testing
        .package(url: "https://github.com/natinusala/Quick.git", .upToNextMajor(from: "1.0.1")),
        .package(url: "https://github.com/Quick/Nimble.git", .upToNextMajor(from: "11.2.1")),
    ],
    targets: [
        // ScarletUI: contains scenes, views, attributes, modifiers as well as the actual rendering runtime
        // on top of ScarletCore. Also exposes ScarletCore for the DSL and custom views.
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
                .product(name: "ShellOut", package: "ShellOut")
            ]
        ),
        // ScarletCore: core library containing the DSL and graph / state management code
        .target(
            name: "ScarletCore",
            dependencies: [
                "Runtime",
                "OpenCombine",
                "Needler",
                .product(name: "ConsoleKit", package: "console-kit"),
                .product(name: "Cutelog", package: "swift-cutelog"),
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "Builders", package: "swift-builders"),
            ],
            exclude: [
                "ComponentNodes/StaticComponentNode.gyb",
                "Views/TupleView.gyb",
                "Views/ViewAttribute.gyb",
            ]
        ),
        // ScarletNative: native code companion to ScarletUI
        .target(
            name: "ScarletNative",
            dependencies: ["GLFW", "CGlad"]
        ),
        // ScarletUITests: UI testing runner for ScarletUI apps
        .target(
            name: "ScarletUITests",
            dependencies: ["ScarletUI"]
        ),
        // Needler: dead simple dependency injection for mocks and stubs
        .target(
            name: "Needler"
        ),
        // ScarletUIDemo: simple ScarletUI demo app
        .executableTarget(
            name: "ScarletUIDemo",
            dependencies: ["ScarletUI"]
        ),
        // Test targets
        // ScarletCore unit tests
        .testTarget(
            name: "CoreUnitTests",
            dependencies: [
                "ScarletCore",
                "Quick",
                "Nimble",
                .product(name: "Backtrace", package: "swift-backtrace"),
            ]
        ),
        // ScarletCore integration tests
        .testTarget(
            name: "CoreIntegrationTests",
            dependencies: [
                "ScarletCore",
                "Quick",
                "Nimble",
                "Needler",
                .product(name: "Backtrace", package: "swift-backtrace"),
            ]
        ),
        // ScarletUI UI tests
        .testTarget(
            name: "UITests",
            dependencies: ["ScarletUITests", "Quick", "Nimble"]
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
