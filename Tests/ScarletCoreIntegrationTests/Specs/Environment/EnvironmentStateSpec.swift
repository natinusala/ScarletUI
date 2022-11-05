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

private enum Signal: Int, TestSignal {
    case increment
}

class EnvironmentStateSpec: ScarletSpec {
    static let describing = "a view with both state and environment values"

    struct EnvironmentAndState: View {
        @Environment(\.test)
        var test

        @State
        private var counter = 0

        var body: some View {
            Text("Test: \(test)")
            Text("Counter: \(counter)")
                .onTestSignal(Signal.increment) {
                    self.counter += 1
                }
        }
    }

    struct Tested: TestView {
        let test: String

        var body: some View {
            EnvironmentAndState()
                .environment(\.test, value: test)
        }

        static func spec() -> Spec {
            when("the view is created") {
                given {
                    Tested(test: "Test")
                }

                then("implementation is created") { result in
                    expect(result.implementation).to(equal(
                        ViewImpl("Tested") {
                            ViewImpl("EnvironmentAndState") {
                                TextImpl(text: "Test: Test")
                                TextImpl(text: "Counter: 0")
                            }
                        }
                    ))
                }
            }

            when("environment is updated") {
                given {
                    Tested(test: "Test")
                    Tested(test: "TestAgain")
                }

                then("implementation is updated") { result in
                    expect(result.implementation).to(equal(
                        ViewImpl("Tested") {
                            ViewImpl("EnvironmentAndState") {
                                TextImpl(text: "Test: TestAgain")
                                TextImpl(text: "Counter: 0")
                            }
                        }
                    ))
                }
            }

            when("environment is updated after a state change") {
                given {
                    Tested(test: "Test")

                    signal(Signal.increment)

                    Tested(test: "TestAgain")
                }

                then("state value and environment are preserved") { result in
                    expect(result.implementation).to(equal(
                        ViewImpl("Tested") {
                            ViewImpl("EnvironmentAndState") {
                                TextImpl(text: "Test: TestAgain")
                                TextImpl(text: "Counter: 1")
                            }
                        }
                    ))
                }
            }

            when("state is updated after an environment change") {
                given {
                    Tested(test: "Test")

                    Tested(test: "TestAgain")

                    signal(Signal.increment)
                }

                then("state value and environment are preserved") { result in
                    expect(result.implementation).to(equal(
                        ViewImpl("Tested") {
                            ViewImpl("EnvironmentAndState") {
                                TextImpl(text: "Test: TestAgain")
                                TextImpl(text: "Counter: 1")
                            }
                        }
                    ))
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
