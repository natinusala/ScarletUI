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

class AccumulatingAttributeMultipleDifferentSpec: ScarletCoreSpec {
    static let describing = "a view with two different accumulating attributes applied"

    struct Tested: TestView {
        let tag: String
        let flag: Flag

        var body: some View {
            Rectangle(color: .orange)
                .tag(tag)
                .flag(flag)
        }

        static func spec() -> Spec {
            when("the view is created") {
                given {
                    Tested(tag: "some-tag", flag: .accessible)
                }

                then("target is created") { result in
                    expect(result.target).to(equal(
                        ViewTarget("Tested") {
                            ViewTarget("Rectangle", tags: ["some-tag"], flags: [.accessible]).anyChildren()
                        }
                    ))
                }
            }

            when("the first attribute changes") {
                given {
                    Tested(tag: "some-tag", flag: .accessible)
                    Tested(tag: "another-tag", flag: .accessible)
                }

                then("target is updated") { result in
                    expect(result.target).to(equal(
                        ViewTarget("Tested") {
                            ViewTarget("Rectangle", tags: ["another-tag"], flags: [.accessible]).anyChildren()
                        }
                    ))
                }

                then("the changed attribute is updated") { result in
                    expect(result.testedChildren[0].attributeChanged(\.tags)).to(beTrue())
                }

                then("the unchanged attribute is untouched") { result in
                    expect(result.testedChildren[0].attributeChanged(\.flags)).to(beFalse())
                }
            }

            when("the second attribute changes") {
                given {
                    Tested(tag: "some-tag", flag: .accessible)
                    Tested(tag: "some-tag", flag: .clickable)
                }

                then("target is updated") { result in
                    expect(result.target).to(equal(
                        ViewTarget("Tested") {
                            ViewTarget("Rectangle", tags: ["some-tag"], flags: [.clickable]).anyChildren()
                        }
                    ))
                }

                then("the changed attribute is updated") { result in
                    expect(result.testedChildren[0].attributeChanged(\.flags)).to(beTrue())
                }

                then("the unchanged attribute is untouched") { result in
                    expect(result.testedChildren[0].attributeChanged(\.tags)).to(beFalse())
                }
            }

            when("both attributes change") {
                given {
                    Tested(tag: "some-tag", flag: .accessible)
                    Tested(tag: "another-tag", flag: .clickable)
                }

                then("target is updated") { result in
                    expect(result.target).to(equal(
                        ViewTarget("Tested") {
                            ViewTarget("Rectangle", tags: ["another-tag"], flags: [.clickable]).anyChildren()
                        }
                    ))
                }

                then("changed attributes are updated") { result in
                    expect(result.testedChildren[0].attributeChanged(\.flags)).to(beTrue())
                    expect(result.testedChildren[0].attributeChanged(\.tags)).to(beTrue())
                }
            }

            when("no attribute change") {
                given {
                    Tested(tag: "some-tag", flag: .accessible)
                    Tested(tag: "some-tag", flag: .accessible)
                }

                then("target is untouched") { result in
                    expect(result.target).to(equal(
                        ViewTarget("Tested") {
                            ViewTarget("Rectangle", tags: ["some-tag"], flags: [.accessible]).anyChildren()
                        }
                    ))
                }

                then("no attributes are changed") { result in
                    expect(result.testedChildren[0].anyAttributeChanged).to(beFalse())
                }
            }
        }
    }
}
