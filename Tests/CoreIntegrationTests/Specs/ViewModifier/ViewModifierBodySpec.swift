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

class ViewModifierBodySpec: ScarletCoreSpec {
    static let describing = "a view modifier"

    struct Modified: View {
        let color: String

        var body: some View {
            Text(color)
        }
    }

    struct Tested: TestView {
        let text: String
        let color: String

        var body: some View {
            Modified(color: color)
                .someModifier(text: text)
        }

        static func spec() -> Spec {
            when("the view is created") {
                given {
                    Tested(text: "some text", color: "orange")
                }

                then("implementation is created") { result in
                    expect(result.implementation).to(equal(
                        ViewImpl("Tested") {
                            ViewImpl("Row") {
                                TextImpl(text: "some text")

                                ViewImpl("Modified") {
                                    TextImpl(text: "orange")
                                }
                            }
                        }
                    ))
                }
            }

            when("the modifier changes") {
                given {
                    Tested(text: "some text", color: "orange")
                    Tested(text: "some other text", color: "orange")
                }

                then("implementation is updated") { result in
                    expect(result.implementation).to(equal(
                        ViewImpl("Tested") {
                            ViewImpl("Row") {
                                TextImpl(text: "some other text")

                                ViewImpl("Modified") {
                                    TextImpl(text: "orange")
                                }
                            }
                        }
                    ))
                }

                then("tested view body is called") { result in
                    expect(result.bodyCalled(of: Tested.self)).to(beTrue())
                }

                then("modifier body is called") { result in
                    expect(result.bodyCalled(of: SomeModifier.self)).to(beTrue())
                }

                then("content body is not called") { result in
                    expect(result.bodyCalled(of: Modified.self)).to(beFalse())
                }
            }

            when("content changes") {
                given {
                    Tested(text: "some text", color: "orange")
                    Tested(text: "some text", color: "blue")
                }

                then("implementation is updated") { result in
                    expect(result.implementation).to(equal(
                        ViewImpl("Tested") {
                            ViewImpl("Row") {
                                TextImpl(text: "some text")

                                ViewImpl("Modified") {
                                    TextImpl(text: "blue")
                                }
                            }
                        }
                    ))
                }

                then("tested view body is called") { result in
                    expect(result.bodyCalled(of: Tested.self)).to(beTrue())
                }

                then("modifier body is not called") { result in
                    expect(result.bodyCalled(of: SomeModifier.self)).to(beFalse())
                }

                then("content body is called") { result in
                    expect(result.bodyCalled(of: Modified.self)).to(beTrue())
                }
            }

            when("both content and modifier change") {
                given {
                    Tested(text: "some text", color: "orange")
                    Tested(text: "some other text", color: "blue")
                }

                then("implementation is unchanged") { result in
                    expect(result.implementation).to(equal(
                        ViewImpl("Tested") {
                            ViewImpl("Row") {
                                TextImpl(text: "some other text")

                                ViewImpl("Modified") {
                                    TextImpl(text: "blue")
                                }
                            }
                        }
                    ))
                }

                then("tested view body is called") { result in
                    expect(result.bodyCalled(of: Tested.self)).to(beTrue())
                }

                then("modifier body is called") { result in
                    expect(result.bodyCalled(of: SomeModifier.self)).to(beTrue())
                }

                then("content body is called") { result in
                    expect(result.bodyCalled(of: Modified.self)).to(beTrue())
                }
            }

            when("nothing changes") {
                given {
                    Tested(text: "some text", color: "orange")
                    Tested(text: "some text", color: "orange")
                }

                then("implementation is unchanged") { result in
                    expect(result.implementation).to(equal(
                        ViewImpl("Tested") {
                            ViewImpl("Row") {
                                TextImpl(text: "some text")

                                ViewImpl("Modified") {
                                    TextImpl(text: "orange")
                                }
                            }
                        }
                    ))
                }

                then("tested view body is called") { result in
                    expect(result.bodyCalled(of: Tested.self)).to(beTrue())
                }

                then("modifier body is not called") { result in
                    expect(result.bodyCalled(of: SomeModifier.self)).to(beFalse())
                }

                then("content body is not called") { result in
                    expect(result.bodyCalled(of: Modified.self)).to(beFalse())
                }
            }
        }
    }
}

private struct SomeModifier: ViewModifier {
    let text: String

    func body(content: Content) -> some View {
        Row {
            Text(text)

            content
        }
    }
}

private extension View {
    func someModifier(text: String) -> some View {
        self.modified(by: SomeModifier(text: text))
    }
}
