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

class AttributeSpec: ScarletCoreSpec {
    static let describing = "a view with a single attribute"

    struct Tested: TestView {
        let rectangleId: String

        var body: some View {
            Rectangle(color: .orange)
                .id(rectangleId)
        }

        static func spec() -> Spec {
            when("the view is created") {
                given {
                    Tested(rectangleId: "some-rectangle")
                }

                then("the attribute is applied") { result in
                    expect(result.target).to(equal(
                        ViewTarget("Tested") {
                            ViewTarget("Rectangle", id: "some-rectangle").anyChildren()
                        }
                    ))
                }
            }

            when("the attribute value changes") {
                given {
                    Tested(rectangleId: "some-rectangle")
                    Tested(rectangleId: "some-other-rectangle")
                }

                then("target is updated") { result in
                    expect(result.target).to(equal(
                        ViewTarget("Tested") {
                            ViewTarget("Rectangle", id: "some-other-rectangle").anyChildren()
                        }
                    ))
                }

                then("value is set on target side") { result in
                    expect(result.testedChildren[0].attributeChanged(\.id)).to(beTrue())
                }

                then("view body is not called") { result in
                    expect(result.bodyCalled(of: Rectangle.self)).to(beFalse())
                }
            }

            when("the attribute value doesn't change") {
                given {
                    Tested(rectangleId: "some-rectangle")
                    Tested(rectangleId: "some-rectangle")
                }

                then("target is kept the same") { result in
                    expect(result.target).to(equal(
                        ViewTarget("Tested") {
                            ViewTarget("Rectangle", id: "some-rectangle").anyChildren()
                        }
                    ))
                }

                then("value is not set on target side") { result in
                    expect(result.testedChildren[0].attributeChanged(\.id)).to(beFalse())
                }

                then("view body is not called") { result in
                    expect(result.bodyCalled(of: Rectangle.self)).to(beFalse())
                }
            }
        }
    }
}
