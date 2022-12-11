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

class DiscardingAttributePropagationOverridingSpec: ScarletSpec {
    static let describing = "a view tree with overridden propagating discarding attributes"

    struct Overridden: View {
        let defaultColor: Color

        var body: some View {
            Text("Some text")

            Text("Some other text")
                .textColor(defaultColor)
        }
    }

    struct Tested: TestView {
        let overriddenColor: Color
        let defaultColor: Color

        var body: some View {
            Text("More text")

            Overridden(defaultColor: defaultColor)
                .textColor(overriddenColor)
        }

        static func spec() -> Spec {
            when("the view tree is created") {
                given {
                    Tested(overriddenColor: .yellow, defaultColor: .blue)
                }

                then("the implementation tree is created") { result in
                    expect(result.implementation).to(equal(
                        ViewImpl("Tested") {
                            TextImpl(text: "More text", textColor: .black)

                            ViewImpl("Overridden") {
                                TextImpl(text: "Some text", textColor: .yellow)
                                TextImpl(text: "Some other text", textColor: .yellow)
                            }
                        }
                    ))
                }
            }

            when("the default color changes") {
                given {
                    Tested(overriddenColor: .yellow, defaultColor: .blue)
                    Tested(overriddenColor: .yellow, defaultColor: .red)
                }

                then("the implementation is untouched") { result in
                    expect(result.implementation).to(equal(
                        ViewImpl("Tested") {
                            TextImpl(text: "More text", textColor: .black)

                            ViewImpl("Overridden") {
                                TextImpl(text: "Some text", textColor: .yellow)
                                TextImpl(text: "Some other text", textColor: .yellow)
                            }
                        }
                    ))
                }

                then("attributes are not set on the implementation side") { result in
                    expect(result.all(TextImpl.self, expectedCount: 3)).to(allPass {
                        $0.textColorChanged == false
                    })
                }
            }

            when("the overridden color changes") {
                given {
                    Tested(overriddenColor: .yellow, defaultColor: .blue)
                    Tested(overriddenColor: .red, defaultColor: .blue)
                }

                then("the implementation is updated") { result in
                    expect(result.implementation).to(equal(
                        ViewImpl("Tested") {
                            TextImpl(text: "More text", textColor: .black)

                            ViewImpl("Overridden") {
                                TextImpl(text: "Some text", textColor: .red)
                                TextImpl(text: "Some other text", textColor: .red)
                            }
                        }
                    ))
                }
            }

            when("nothing changes") {
                given {
                    Tested(overriddenColor: .yellow, defaultColor: .blue)
                    Tested(overriddenColor: .yellow, defaultColor: .blue)
                }

                then("the implementation is untouched") { result in
                    expect(result.implementation).to(equal(
                        ViewImpl("Tested") {
                            TextImpl(text: "More text", textColor: .black)

                            ViewImpl("Overridden") {
                                TextImpl(text: "Some text", textColor: .yellow)
                                TextImpl(text: "Some other text", textColor: .yellow)
                            }
                        }
                    ))
                }

                then("attributes are not set on the implementation side") { result in
                    expect(result.all(TextImpl.self, expectedCount: 3)).to(allPass {
                        $0.textColorChanged == false
                    })
                }
            }
        }
    }
}
