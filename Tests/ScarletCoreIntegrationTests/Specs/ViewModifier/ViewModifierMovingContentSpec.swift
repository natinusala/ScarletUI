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

class ViewModifierTogglingContentSpec: ScarletSpec {
    static let describing = "a view modifier with state changes toggling its content"

    struct Modified: View {
        @State 
        private var count = 0

        var body: some View {
            Text("Count: \(count)")
                .onTestSignal(Signal.increment) {
                    self.count += 1
                }
        }
    }

    struct Tested: TestView {
        var body: some View {
            Modified()
                .someModifier()
        }

        static func spec() -> Spec {
            when("the view is created with the toggle off") {
                given {
                    Tested()
                }

                then("implementation is created") { result in
                    expect(result.implementation).to(equal(
                        ViewImpl("Tested") {
                            ViewImpl("Row")
                        }
                    ))
                }
            }

            when("the view modifier state changes to display the view") {
                given {
                    Tested()

                    signal(Signal.toggle)
                }

                then("modifier body is called") { result in
                    expect(result.bodyCalled(of: SomeModifier.self)).to(be(true))
                }

                then("modified view body is called") { result in
                    expect(result.bodyCalled(of: Modified.self)).to(be(true))
                }

                then("implementation is updated") { result in
                    expect(result.implementation).to(equal(
                        ViewImpl("Tested") {
                            ViewImpl("Row") {
                                TextImpl(text: "Toggle: true")

                                ViewImpl("Modified") {
                                    TextImpl(text: "Count: 0")
                                }
                            }
                        }
                    ))
                }
            }

            when("the view modifier state changes to display and remove the view") {
                given {
                    Tested()

                    signal(Signal.toggle)
                    signal(Signal.toggle)
                }

                then("modifier body is called") { result in
                    expect(result.bodyCalled(of: SomeModifier.self)).to(be(true))
                }

                then("modified view body is called") { result in
                    expect(result.bodyCalled(of: Modified.self)).to(be(true))
                }

                then("implementation is updated") { result in
                    expect(result.implementation).to(equal(
                        ViewImpl("Tested") {
                            ViewImpl("Row")
                        }
                    ))
                }
            }

            when("the modified view state changes") {
                given {
                    Tested()

                    signal(Signal.toggle)
                    signal(Signal.increment)
                }

                then("modifier body is called") { result in
                    expect(result.bodyCalled(of: SomeModifier.self)).to(be(true))
                }

                then("modified view body is called") { result in
                    expect(result.bodyCalled(of: Modified.self)).to(be(true))
                }

                then("implementation is updated") { result in
                    expect(result.implementation).to(equal(
                        ViewImpl("Tested") {
                            ViewImpl("Row") {
                                TextImpl(text: "Toggle: true")

                                ViewImpl("Modified") {
                                    TextImpl(text: "Count: 1")
                                }
                            }
                        }
                    ))
                }
            }

            when("sending a signal to the removed view") {
                given {
                    Tested()

                    signal(Signal.toggle)
                    signal(Signal.toggle)

                    signal(Signal.increment)
                }

                then("modifier body is called") { result in
                    expect(result.bodyCalled(of: SomeModifier.self)).to(be(true))
                }

                then("modified view body is called") { result in
                    expect(result.bodyCalled(of: Modified.self)).to(be(true))
                }

                then("implementation is updated") { result in
                    expect(result.implementation).to(equal(
                        ViewImpl("Tested") {
                            ViewImpl("Row")
                        }
                    ))
                }
            }
        }
    }
}

private struct SomeModifier: ViewModifier {
    @State
    private var toggle = false

    func body(content: Content) -> some View {
        Row {
            if toggle {
                Text("Toggle: \(toggle)")

                content
            }
        }
        .onTestSignal(Signal.toggle) {
            self.toggle.toggle()
        }
    }
}

private extension View {
    func someModifier() -> some View {
        self.modified(by: SomeModifier())
    }
}

private enum Signal: Int, TestSignal {
    case toggle
    case increment
}
