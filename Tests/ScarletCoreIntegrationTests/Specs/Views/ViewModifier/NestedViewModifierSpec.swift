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

class NestedViewModifierSpec: ScarletSpec {
    static let describing = "a view with multiple modifiers applied"

    struct Modified: View {
        let color: String

        var body: some View {
            Text(color)
        }
    }

    struct Tested: TestView {
        var body: some View {
            Modified(color: "yellow")
                .someModifier(text: "some modifier")
                .anotherModifier(icon: "info")
        }

        static func spec() -> Specs {
            when("the view is created") {
                given {
                    Tested()
                }

                then("implementation is created") { result in
                    expect(result.implementation).to(equal(
                        ViewImpl("Tested") {
                            ViewImpl("Row") {
                                TextImpl(text: "some modifier")

                                ViewImpl("Modified") {
                                    TextImpl(text: "yellow")
                                }
                            }

                            ImageImpl(source: "icon-info.png")
                        }
                    ))
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
        self.modifier(SomeModifier(text: text))
    }
}

private struct AnotherModifier: ViewModifier {
    let icon: String

    func body(content: Content) -> some View {
        content

        Image(source: "icon-\(icon).png")
    }
}

private extension View {
    func anotherModifier(icon: String) -> some View {
        self.modifier(AnotherModifier(icon: icon))
    }
}
