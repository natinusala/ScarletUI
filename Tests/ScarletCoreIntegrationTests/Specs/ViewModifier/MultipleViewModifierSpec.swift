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

class MultipleViewModifierSpec: ScarletSpec {
    static let describing = "a view with multiple modifiers applied"

    struct Modified: View {
        let color: String

        var body: some View {
            Text(color)
        }
    }

    struct Tested: TestView {
        let modifiedColor: String
        let someModifierText: String
        let anotherModifierIcon: String

        var body: some View {
            Modified(color: modifiedColor)
                .someModifier(text: someModifierText)
                .anotherModifier(icon: anotherModifierIcon)
        }

        static func spec() -> Spec {
            when("the view is created") {
                given {
                    Tested(modifiedColor: "yellow", someModifierText: "some modifier", anotherModifierIcon: "info")
                }

                then("implementation is created") { result in
                    expect(result.implementation).to(equal(
                        ViewImpl("Tested") {
                            TextImpl(text: "Wrapping starts")

                            ViewImpl("Row") {
                                TextImpl(text: "some modifier")

                                ViewImpl("Modified") {
                                    TextImpl(text: "yellow")
                                }
                            }

                            ImageImpl(source: "icon-info.png")

                            TextImpl(text: "Wrapping ends")
                        }
                    ))
                }
            }

            when("nothing changes") {
                given {
                    Tested(modifiedColor: "yellow", someModifierText: "some modifier", anotherModifierIcon: "info")
                    Tested(modifiedColor: "yellow", someModifierText: "some modifier", anotherModifierIcon: "info")
                }

                then("implementation is untouched") { result in
                    expect(result.implementation).to(equal(
                        ViewImpl("Tested") {
                            TextImpl(text: "Wrapping starts")

                            ViewImpl("Row") {
                                TextImpl(text: "some modifier")

                                ViewImpl("Modified") {
                                    TextImpl(text: "yellow")
                                }
                            }

                            ImageImpl(source: "icon-info.png")

                            TextImpl(text: "Wrapping ends")
                        }
                    ))
                }

                then("tested view body is called") { result in
                    expect(result.bodyCalled(of: Tested.self)).to(beTrue())
                }

                then("modified view body is not called") { result in
                    expect(result.bodyCalled(of: Modified.self)).to(beFalse())
                }

                then("modifier 1 body is not called") { result in
                    expect(result.bodyCalled(of: SomeModifier.self)).to(beFalse())
                }

                then("modifier 2 body is not called") { result in
                    expect(result.bodyCalled(of: AnotherModifier.self)).to(beFalse())
                }
            }

            when("modified view is modified") {
                given {
                    Tested(modifiedColor: "yellow", someModifierText: "some modifier", anotherModifierIcon: "info")
                    Tested(modifiedColor: "orange", someModifierText: "some modifier", anotherModifierIcon: "info")
                }

                then("implementation is updated") { result in
                    expect(result.implementation).to(equal(
                        ViewImpl("Tested") {
                            TextImpl(text: "Wrapping starts")

                            ViewImpl("Row") {
                                TextImpl(text: "some modifier")

                                ViewImpl("Modified") {
                                    TextImpl(text: "orange")
                                }
                            }

                            ImageImpl(source: "icon-info.png")

                            TextImpl(text: "Wrapping ends")
                        }
                    ))
                }

                then("tested view body is called") { result in
                    expect(result.bodyCalled(of: Tested.self)).to(beTrue())
                }

                then("modified view body is called") { result in
                    expect(result.bodyCalled(of: Modified.self)).to(beTrue())
                }

                then("modifier 1 body is not called") { result in
                    expect(result.bodyCalled(of: SomeModifier.self)).to(beFalse())
                }

                then("modifier 2 body is not called") { result in
                    expect(result.bodyCalled(of: AnotherModifier.self)).to(beFalse())
                }
            }

            when("modifier 1 is modified") {
                given {
                    Tested(modifiedColor: "yellow", someModifierText: "some modifier", anotherModifierIcon: "info")
                    Tested(modifiedColor: "yellow", someModifierText: "some changed modifier", anotherModifierIcon: "info")
                }

                then("implementation is updated") { result in
                    expect(result.implementation).to(equal(
                        ViewImpl("Tested") {
                            TextImpl(text: "Wrapping starts")

                            ViewImpl("Row") {
                                TextImpl(text: "some changed modifier")

                                ViewImpl("Modified") {
                                    TextImpl(text: "yellow")
                                }
                            }

                            ImageImpl(source: "icon-info.png")

                            TextImpl(text: "Wrapping ends")
                        }
                    ))
                }

                then("tested view body is called") { result in
                    expect(result.bodyCalled(of: Tested.self)).to(beTrue())
                }

                then("modified view body is not called") { result in
                    expect(result.bodyCalled(of: Modified.self)).to(beFalse())
                }

                then("modifier 1 body is called") { result in
                    expect(result.bodyCalled(of: SomeModifier.self)).to(beTrue())
                }

                then("modifier 2 body is not called") { result in
                    expect(result.bodyCalled(of: AnotherModifier.self)).to(beFalse())
                }
            }

            when("modifier 2 is modified") {
                given {
                    Tested(modifiedColor: "yellow", someModifierText: "some modifier", anotherModifierIcon: "info")
                    Tested(modifiedColor: "yellow", someModifierText: "some changed modifier", anotherModifierIcon: "info")
                }

                then("implementation is updated") { result in
                    expect(result.implementation).to(equal(
                        ViewImpl("Tested") {
                            TextImpl(text: "Wrapping starts")

                            ViewImpl("Row") {
                                TextImpl(text: "some changed modifier")

                                ViewImpl("Modified") {
                                    TextImpl(text: "yellow")
                                }
                            }

                            ImageImpl(source: "icon-info.png")

                            TextImpl(text: "Wrapping ends")
                        }
                    ))
                }

                then("tested view body is called") { result in
                    expect(result.bodyCalled(of: Tested.self)).to(beTrue())
                }

                then("modified view body is not called") { result in
                    expect(result.bodyCalled(of: Modified.self)).to(beFalse())
                }

                then("modifier 1 body is called") { result in
                    expect(result.bodyCalled(of: SomeModifier.self)).to(beTrue())
                }

                then("modifier 2 body is not called") { result in
                    expect(result.bodyCalled(of: AnotherModifier.self)).to(beFalse())
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
        return self.modified(by: SomeModifier(text: text))
    }
}

private struct AnotherModifier: ViewModifier {
    let icon: String

    func body(content: Content) -> some View {
        Text("Wrapping starts")

        content

        Image(source: "icon-\(icon).png")

        Text("Wrapping ends")
    }
}

private extension View {
    func anotherModifier(icon: String) -> some View {
        self.modified(by: AnotherModifier(icon: icon))
    }
}
