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

class DiscardingAttributeNonPropagationSpec: ScarletSpec {
    static let describing = "a view tree with a non-propagating discarding attribute on the top-level"

    struct Avatar: View {
        let user: String

        var body: some View {
            Image(source: "avatar://\(user)")
                .id("avatar-\(user)")
        }
    }

    struct Header: View {
        let user: String

        var body: some View {
            Avatar(user: user)
            Text(user)
        }
    }

    struct Tested: TestView {
        let user: String
        let headerId: String

        var body: some View {
            Header(user: user)
                .id(headerId)
        }

        static func spec() -> Spec {
            when("the view is created") {
                given {
                    Tested(user: "Kirby", headerId: "main-content-header")
                }

                then("the implementation tree is created") { result in
                    expect(result.implementation).to(equal(
                        ViewImpl("Tested") {
                            ViewImpl("Header", id: "main-content-header") {
                                ViewImpl("Avatar") {
                                    ImageImpl(source: "avatar://Kirby", id: "avatar-Kirby")
                                }

                                TextImpl(text: "Kirby")
                            }
                        }
                    ))
                }
            }

            when("nothing changes") {
                given {
                    Tested(user: "Kirby", headerId: "main-content-header")
                    Tested(user: "Kirby", headerId: "main-content-header")
                }

                then("the implementation tree is untouched") { result in
                    expect(result.implementation).to(equal(
                        ViewImpl("Tested") {
                            ViewImpl("Header", id: "main-content-header") {
                                ViewImpl("Avatar") {
                                    ImageImpl(source: "avatar://Kirby", id: "avatar-Kirby")
                                }

                                TextImpl(text: "Kirby")
                            }
                        }
                    ))
                }

                then("attributes are not set on the implementation side") { result in
                    expect(result.allViews).to(allPass { view in
                        view.anyAttributeChanged == false
                    })
                }
            }

            when("the attribute changes") {
                given {
                    Tested(user: "Kirby", headerId: "main-content-header")
                    Tested(user: "Kirby", headerId: "main-content-header-invalidated")
                }

                then("the implementation tree is updated") { result in
                    expect(result.implementation).to(equal(
                        ViewImpl("Tested") {
                            ViewImpl("Header", id: "main-content-header-invalidated") {
                                ViewImpl("Avatar") {
                                    ImageImpl(source: "avatar://Kirby", id: "avatar-Kirby")
                                }

                                TextImpl(text: "Kirby")
                            }
                        }
                    ))
                }

                then("attribute is set on the implementation side") { result in
                    expect(result.first("Header").attributeChanged(\.id)).to(beTrue())
                }
            }
        }
    }
}
