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

/// Child environment takes precedence over the parent (parent tries to "override").
class EnvironmentAttributeAlreadySetSpec: ScarletCoreSpec {
    static let describing = "a view with an environment attribute already by the parent"

    struct ColoredContent: View {
        let color: Color

        var body: some View {
            Text("Content text")
                .textColor(color)
        }
    }

    struct Tested: TestView {
        let overrideColor: Bool
        let overriddenColor: Color

        var body: some View {
            if overrideColor {
                ColoredContent(color: .white)
                    .textColor(overriddenColor)
            } else {
                ColoredContent(color: .orange)
            }
        }

        static func spec() -> Spec {
            when("the view is created with no override") {
                given {
                    Tested(overrideColor: false, overriddenColor: .yellow)
                }

                then("target is created") { result in
                    expect(result.target).to(equal(
                        ViewTarget("Tested") {
                            ViewTarget("ColoredContent") {
                                TextTarget(text: "Content text", textColor: .orange)
                            }
                        }
                    ))
                }
            }

            when("the overridden color is updated with no override") {
                given {
                    Tested(overrideColor: false, overriddenColor: .yellow)
                    Tested(overrideColor: false, overriddenColor: .blue)
                }

                then("target is untouched") { result in
                    expect(result.target).to(equal(
                        ViewTarget("Tested") {
                            ViewTarget("ColoredContent") {
                                TextTarget(text: "Content text", textColor: .orange)
                            }
                        }
                    ))
                }

                then("value is not set on target side") { result in
                    expect(result.first(TextTarget.self).textColorChanged).to(beFalse())
                }

                then("view body is not called") { result in
                    expect(result.bodyCalled(of: ColoredContent.self)).to(beFalse())
                }
            }

            when("the view is created with an override") {
                given {
                    Tested(overrideColor: true, overriddenColor: .yellow)
                }

                then("target is created") { result in
                    expect(result.target).to(equal(
                        ViewTarget("Tested") {
                            ViewTarget("ColoredContent") {
                                TextTarget(text: "Content text", textColor: .white)
                            }
                        }
                    ))
                }
            }

            when("the overridden color is updated") {
                given {
                    Tested(overrideColor: true, overriddenColor: .yellow)
                    Tested(overrideColor: true, overriddenColor: .blue)
                }

                then("target is updated") { result in
                    expect(result.target).to(equal(
                        ViewTarget("Tested") {
                            ViewTarget("ColoredContent") {
                                TextTarget(text: "Content text", textColor: .white)
                            }
                        }
                    ))
                }

                then("value is not set on target side") { result in
                    expect(result.first(TextTarget.self).textColorChanged).to(beFalse())
                }

                then("view body is not called") { result in
                    expect(result.bodyCalled(of: ColoredContent.self)).to(beFalse())
                }
            }

            when("the overridden color does not change") {
                given {
                    Tested(overrideColor: true, overriddenColor: .yellow)
                    Tested(overrideColor: true, overriddenColor: .yellow)
                }

                then("target is untouched") { result in
                    expect(result.target).to(equal(
                        ViewTarget("Tested") {
                            ViewTarget("ColoredContent") {
                                TextTarget(text: "Content text", textColor: .white)
                            }
                        }
                    ))
                }

                then("value is not set on target side") { result in
                    expect(result.first(TextTarget.self).textColorChanged).to(beFalse())
                }

                then("view body is not called") { result in
                    expect(result.bodyCalled(of: ColoredContent.self)).to(beFalse())
                }
            }

            when("the overridden color is disabled") {
                given {
                    Tested(overrideColor: true, overriddenColor: .yellow)
                    Tested(overrideColor: false, overriddenColor: .blue)
                }

                then("target is updated") { result in
                    expect(result.target).to(equal(
                        ViewTarget("Tested") {
                            ViewTarget("ColoredContent") {
                                TextTarget(text: "Content text", textColor: .orange)
                            }
                        }
                    ))
                }

                then("value is set on target side") { result in
                    expect(result.first(TextTarget.self).textColorChanged).to(beTrue())
                }

                then("view body is called") { result in
                    // Because a new view is created
                    expect(result.bodyCalled(of: ColoredContent.self)).to(beTrue())
                }
            }

            when("the overridden color is enabled") {
                given {
                    Tested(overrideColor: false, overriddenColor: .yellow)
                    Tested(overrideColor: true, overriddenColor: .blue)
                }

                then("target is updated") { result in
                    expect(result.target).to(equal(
                        ViewTarget("Tested") {
                            ViewTarget("ColoredContent") {
                                TextTarget(text: "Content text", textColor: .white)
                            }
                        }
                    ))
                }

                then("value is set on target side") { result in
                    expect(result.first(TextTarget.self).textColorChanged).to(beTrue())
                }

                then("view body is called") { result in
                    // Because a new view is created
                    expect(result.bodyCalled(of: ColoredContent.self)).to(beTrue())
                }
            }
        }
    }
}
