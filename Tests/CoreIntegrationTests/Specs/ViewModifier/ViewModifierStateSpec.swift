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

class ViewModifierStateSpec: ScarletCoreSpec {
    static let describing = "a view modifier with state changes"

    struct Tested: TestView {
        var body: some View {
            Text("Hello World")
                .someModifier()
        }

        static func spec() -> Spec {
            when("the view is created") {
                given {
                    Tested()
                }

                then("target is created") { result in
                    expect(result.target).to(equal(
                        ViewTarget("Tested") {
                            ViewTarget("Row") {
                                TextTarget(text: "Count: 0")

                                TextTarget(text: "Hello World")
                            }
                        }
                    ))
                }
            }

            when("a state change occurs") {
                given {
                    Tested()

                    signal(Signal.increment)
                }

                then("modifier body is called") { result in
                    expect(result.bodyCalled(of: SomeModifier.self)).to(equal(true))
                }

                then("target is updated") { result in
                    expect(result.target).to(equal(
                        ViewTarget("Tested") {
                            ViewTarget("Row") {
                                TextTarget(text: "Count: 1")

                                TextTarget(text: "Hello World")
                            }
                        }
                    ))
                }
            }

            when("mutliple state changes occur") {
                given {
                    Tested()

                    signal(Signal.increment)
                    signal(Signal.increment)
                    signal(Signal.increment)
                    signal(Signal.increment)
                    signal(Signal.increment)
                }

                then("modifier body is called") { result in
                    expect(result.bodyCalled(of: SomeModifier.self)).to(equal(true))
                }

                then("target is updated") { result in
                    expect(result.target).to(equal(
                        ViewTarget("Tested") {
                            ViewTarget("Row") {
                                TextTarget(text: "Count: 5")

                                TextTarget(text: "Hello World")

                                TextTarget(text: "Jackpot!")
                            }
                        }
                    ))
                }
            }
        }
    }
}

private struct SomeModifier: ViewModifier {
    @State
    private var count = 0

    func body(content: Content) -> some View {
        Row {
            Text("Count: \(count)")

            content

            if count >= 5 {
                Text("Jackpot!")
            }
        }
        .onTestSignal(Signal.increment) {
            self.count += 1
        }
    }
}

private extension View {
    func someModifier() -> some View {
        self.modified(by: SomeModifier())
    }
}

private enum Signal: Int, TestSignal {
    case increment
}
