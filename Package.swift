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
    ],
    targets: [
        .target(
            name: "ScarletCore",
            dependencies: []
        ),
        .target(
            name: "ScarletUI",
            dependencies: ["ScarletCore"]
        ),
        .executableTarget(
            name: "ScarletUIDemo",
            dependencies: ["ScarletUI"]
        ),
        .testTarget(
            name: "ScarletCoreTests",
            dependencies: ["ScarletCore", "Nimble", "Quick", .product(name: "Backtrace", package: "swift-backtrace")]
        ),
    ]
)
