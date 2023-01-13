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

class AttributesDifferentSpec: ScarletCoreSpec {
    static let describing = "a view with the multiple different attributes applied"

    struct Tested: TestView {
        let fill: Color
        let grow: Float

        var body: some View {
            Rectangle(color: .orange)
                .id("some-rectangle")
                .fill(color: fill)
                .grow(grow)
        }

        static func spec() -> Spec {
            when("the view is created") {
                given {
                    Tested(fill: .orange, grow: 0.75)
                }

                then("attributes are applied") { result in
                    expect(result.target).to(equal(
                        ViewTarget("Tested") {
                            ViewTarget("Rectangle", id: "some-rectangle", fill: .orange, grow: 0.75).anyChildren()
                        }
                    ))
                }
            }

            when("attributes values doesn't change") {
                given {
                    Tested(fill: .orange, grow: 0.75)
                    Tested(fill: .orange, grow: 0.75)
                }

                then("attributes are unchanged") { result in
                    expect(result.target).to(equal(
                        ViewTarget("Tested") {
                            ViewTarget("Rectangle", id: "some-rectangle", fill: .orange, grow: 0.75).anyChildren()
                        }
                    ))
                }

                then("values are not set on the target") { result in
                    expect(result.testedChildren[0].attributeChanged(\.id)).to(beFalse())
                    expect(result.testedChildren[0].attributeChanged(\.fill)).to(beFalse())
                    expect(result.testedChildren[0].attributeChanged(\.grow)).to(beFalse())
                }
            }

            when("first attribute value changes") {
                given {
                    Tested(fill: .orange, grow: 0.75)
                    Tested(fill: .blue, grow: 0.75)
                }

                then("attributes are changed") { result in
                    expect(result.target).to(equal(
                        ViewTarget("Tested") {
                            ViewTarget("Rectangle", id: "some-rectangle", fill: .blue, grow: 0.75).anyChildren()
                        }
                    ))
                }

                then("values are set on the target") { result in
                    expect(result.testedChildren[0].attributeChanged(\.id)).to(beFalse())
                    expect(result.testedChildren[0].attributeChanged(\.fill)).to(beTrue())
                    expect(result.testedChildren[0].attributeChanged(\.grow)).to(beFalse())
                }
            }

            when("second attribute value changes") {
                given {
                    Tested(fill: .orange, grow: 0.75)
                    Tested(fill: .orange, grow: 1)
                }

                then("attributes are changed") { result in
                    expect(result.target).to(equal(
                        ViewTarget("Tested") {
                            ViewTarget("Rectangle", id: "some-rectangle", fill: .orange, grow: 1).anyChildren()
                        }
                    ))
                }

                then("values are set on the target") { result in
                    expect(result.testedChildren[0].attributeChanged(\.id)).to(beFalse())
                    expect(result.testedChildren[0].attributeChanged(\.fill)).to(beFalse())
                    expect(result.testedChildren[0].attributeChanged(\.grow)).to(beTrue())
                }
            }

            when("both attributes values change") {
                given {
                    Tested(fill: .orange, grow: 0.75)
                    Tested(fill: .blue, grow: 1)
                }

                then("attributes are changed") { result in
                    expect(result.target).to(equal(
                        ViewTarget("Tested") {
                            ViewTarget("Rectangle", id: "some-rectangle", fill: .blue, grow: 1).anyChildren()
                        }
                    ))
                }

                then("values are set on the target") { result in
                    expect(result.testedChildren[0].attributeChanged(\.id)).to(beFalse())
                    expect(result.testedChildren[0].attributeChanged(\.fill)).to(beTrue())
                    expect(result.testedChildren[0].attributeChanged(\.grow)).to(beTrue())
                }
            }
        }
    }
}
