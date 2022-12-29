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

class AttributeSpreadingSpec: ScarletSpec {
    static let describing = "a view with a attribute spread to multiple views"

    struct Texts: View {
        var body: some View {
            Text("First text")
            Text("Second text")
        }
    }

    struct Tested: TestView {
        let textColor: Color

        var body: some View {
            Texts()
                .textColor(textColor)
        }

        static func spec() -> Spec {
            when("the view is created") {
                given {
                    Tested(textColor: .yellow)
                }

                then("implementation is created") { result in
                    expect(result.implementation).to(equal(
                        ViewImpl("Tested") {
                            ViewImpl("Texts") {
                                TextImpl(text: "First text", textColor: .yellow)
                                TextImpl(text: "Second text", textColor: .yellow)
                            }
                        }
                    ))
                }
            }

            when("the attribute value doesn't change") {
                given {
                    Tested(textColor: .yellow)
                    Tested(textColor: .yellow)
                }

                then("implementation is untouched") { result in
                    expect(result.implementation).to(equal(
                        ViewImpl("Tested") {
                            ViewImpl("Texts") {
                                TextImpl(text: "First text", textColor: .yellow)
                                TextImpl(text: "Second text", textColor: .yellow)
                            }
                        }
                    ))
                }

                then("attributes are not set on the implementation side") { result in
                    let views = result.all(TextImpl.self, expectedCount: 2)
                    expect(views).to(allPass {
                        $0.textColorChanged == false
                    })
                }
            }

            when("the attribute value changes") {
                given {
                    Tested(textColor: .yellow)
                    Tested(textColor: .blue)
                }

                then("implementation is untouched") { result in
                    expect(result.implementation).to(equal(
                        ViewImpl("Tested") {
                            ViewImpl("Texts") {
                                TextImpl(text: "First text", textColor: .blue)
                                TextImpl(text: "Second text", textColor: .blue)
                            }
                        }
                    ))
                }

                then("attributes are not set on the implementation side") { result in
                    let views = result.all(TextImpl.self, expectedCount: 2)
                    expect(views).to(allPass {
                        $0.textColorChanged == true
                    })
                }
            }
        }
    }
}
