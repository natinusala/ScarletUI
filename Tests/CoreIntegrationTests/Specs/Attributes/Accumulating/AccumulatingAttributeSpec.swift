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

class AccumulatingAttributeSpec: ScarletCoreSpec {
    static let describing = "a view with one accumulating attribute"

    struct Tested: TestView {
        let tag: String

        var body: some View {
            Rectangle(color: .white)
                .tag(tag)
        }

        static func spec() -> Spec {
            when("the view is created") {
                given {
                    Tested(tag: "some-tag")
                }

                then("the target is created") { result in
                    expect(result.target).to(equal(
                        ViewTarget("Tested") {
                            ViewTarget("Rectangle", tags: ["some-tag"]).anyChildren()
                        }
                    ))
                }
            }

            when("the value doesn't change") {
                given {
                    Tested(tag: "some-tag")
                    Tested(tag: "some-tag")
                }

                then("the target is untouched") { result in
                    expect(result.target).to(equal(
                        ViewTarget("Tested") {
                            ViewTarget("Rectangle", tags: ["some-tag"]).anyChildren()
                        }
                    ))
                }

                then("attribute is not applied on the target side") { result in
                    expect(result.testedChildren[0].anyAttributeChanged).to(beFalse())
                }

                then("view body is not called") { result in
                    expect(result.bodyCalled(of: Rectangle.self)).to(beFalse())
                }
            }

            when("the value changes") {
                given {
                    Tested(tag: "some-tag")
                    Tested(tag: "another-tag")
                }

                then("the target is untouched") { result in
                    expect(result.target).to(equal(
                        ViewTarget("Tested") {
                            ViewTarget("Rectangle", tags: ["another-tag"]).anyChildren()
                        }
                    ))
                }

                then("attribute is not applied on the target side") { result in
                    expect(result.testedChildren[0].attributeChanged(\.tags)).to(beTrue())
                }

                then("view body is not called") { result in
                    expect(result.bodyCalled(of: Rectangle.self)).to(beFalse())
                }
            }
        }
    }
}
