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

import Nimble

@testable import ScarletCore

class EnvironmentValueSpec: ScarletCoreSpec {
    static let describing = "a view setting environment values"

    struct EnvironmentDisplay: View {
        @Environment(\.test)
        var test

        @Environment(\.immutable)
        var immutable

        var body: some View {
            Text("Environment value: \(test)")
            Text("Immutable environment value: \(immutable)")
        }
    }

    struct Tested: TestView {
        let value: String
        let unused: String

        @Environment(\.test)
        var test

        var body: some View {
            Text("Environment value: \(test)")

            EnvironmentDisplay()
                .environment(\.test, value: value)
                .environment(\.unused, value: unused)
        }

        static func spec() -> Spec {
            when("the view is created") {
                given {
                    Tested(value: "hello", unused: "unused")
                }

                then("target is created") { result in
                    expect(result.target).to(equal(
                        ViewTarget("Tested") {
                            TextTarget(text: "Environment value: default value")

                            ViewTarget("EnvironmentDisplay") {
                                TextTarget(text: "Environment value: hello")
                                TextTarget(text: "Immutable environment value: immutable")
                            }
                        }
                    ))
                }
            }

            when("the environment value is changed") {
                given {
                    Tested(value: "hello", unused: "unused")
                    Tested(value: "world", unused: "unused")
                }

                then("target is updated") { result in
                    expect(result.target).to(equal(
                        ViewTarget("Tested") {
                            TextTarget(text: "Environment value: default value")

                            ViewTarget("EnvironmentDisplay") {
                                TextTarget(text: "Environment value: world")
                                TextTarget(text: "Immutable environment value: immutable")
                            }
                        }
                    ))
                }

                then("wrapped body is called") { result in
                    expect(result.bodyCalled(of: EnvironmentDisplay.self)).to(beTrue())
                }
            }

            when("the environment value is changed multiple times") {
                given {
                    Tested(value: "hello", unused: "unused")
                    Tested(value: "world", unused: "unused")
                    Tested(value: "foo", unused: "unused")
                    Tested(value: "bar", unused: "unused")
                }

                then("target is updated") { result in
                    expect(result.target).to(equal(
                        ViewTarget("Tested") {
                            TextTarget(text: "Environment value: default value")

                            ViewTarget("EnvironmentDisplay") {
                                TextTarget(text: "Environment value: bar")
                                TextTarget(text: "Immutable environment value: immutable")
                            }
                        }
                    ))
                }

                then("wrapped body is called") { result in
                    expect(result.bodyCalled(of: EnvironmentDisplay.self)).to(beTrue())
                }
            }

            when("the environment value is unchanged") {
                given {
                    Tested(value: "hello", unused: "unused")
                    Tested(value: "hello", unused: "unused")
                }

                then("target is unchanged") { result in
                    expect(result.target).to(equal(
                        ViewTarget("Tested") {
                            TextTarget(text: "Environment value: default value")

                            ViewTarget("EnvironmentDisplay") {
                                TextTarget(text: "Environment value: hello")
                                TextTarget(text: "Immutable environment value: immutable")
                            }
                        }
                    ))
                }

                then("wrapped body is not called") { result in
                    expect(result.bodyCalled(of: EnvironmentDisplay.self)).to(beFalse())
                }
            }

            when("an ununsed environment value is unchanged") {
                given {
                    Tested(value: "hello", unused: "unused")
                    Tested(value: "hello", unused: "used!!!")
                }

                then("target is unchanged") { result in
                    expect(result.target).to(equal(
                        ViewTarget("Tested") {
                            TextTarget(text: "Environment value: default value")

                            ViewTarget("EnvironmentDisplay") {
                                TextTarget(text: "Environment value: hello")
                                TextTarget(text: "Immutable environment value: immutable")
                            }
                        }
                    ))
                }

                then("wrapped body is not called") { result in
                    expect(result.bodyCalled(of: EnvironmentDisplay.self)).to(beFalse())
                }
            }
        }
    }
}

private struct TestEnvironmentKey: EnvironmentKey {
    static let defaultValue = "default value"
}

private extension EnvironmentValues {
    var test: String {
        get { self[TestEnvironmentKey.self] }
        set { self[TestEnvironmentKey.self] = newValue }
    }
}

private struct ImmutableEnvironmentKey: EnvironmentKey {
    static let defaultValue = "immutable"
}

private extension EnvironmentValues {
    var immutable: String {
        get { self[ImmutableEnvironmentKey.self] }
        set { self[ImmutableEnvironmentKey.self] = newValue }
    }
}

private struct UnusedEnvironmentKey: EnvironmentKey {
    static let defaultValue = "unused"
}

private extension EnvironmentValues {
    var unused: String {
        get { self[UnusedEnvironmentKey.self] }
        set { self[UnusedEnvironmentKey.self] = newValue }
    }
}
