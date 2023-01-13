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

class EnvironmentAttributePropagationOverridingSpec: ScarletCoreSpec {
    static let describing = "a view tree with overridden environment attributes"

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

                then("the target tree is created") { result in
                    expect(result.target).to(equal(
                        ViewTarget("Tested") {
                            TextTarget(text: "More text", textColor: .black)

                            ViewTarget("Overridden") {
                                TextTarget(text: "Some text", textColor: .yellow)
                                TextTarget(text: "Some other text", textColor: .blue)
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

                then("the target is updated") { result in
                    expect(result.target).to(equal(
                        ViewTarget("Tested") {
                            TextTarget(text: "More text", textColor: .black)

                            ViewTarget("Overridden") {
                                TextTarget(text: "Some text", textColor: .yellow)
                                TextTarget(text: "Some other text", textColor: .red)
                            }
                        }
                    ))
                }
            }

            when("the overridden color changes") {
                given {
                    Tested(overriddenColor: .yellow, defaultColor: .blue)
                    Tested(overriddenColor: .red, defaultColor: .blue)
                }

                then("the target is updated") { result in
                    expect(result.target).to(equal(
                        ViewTarget("Tested") {
                            TextTarget(text: "More text", textColor: .black)

                            ViewTarget("Overridden") {
                                TextTarget(text: "Some text", textColor: .red)
                                TextTarget(text: "Some other text", textColor: .blue)
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

                then("the target is untouched") { result in
                    expect(result.target).to(equal(
                        ViewTarget("Tested") {
                            TextTarget(text: "More text", textColor: .black)

                            ViewTarget("Overridden") {
                                TextTarget(text: "Some text", textColor: .yellow)
                                TextTarget(text: "Some other text", textColor: .blue)
                            }
                        }
                    ))
                }

                then("attributes are not set on the target side") { result in
                    expect(result.all(TextTarget.self, expectedCount: 3)).to(allPass {
                        $0.textColorChanged == false
                    })
                }
            }
        }
    }
}
