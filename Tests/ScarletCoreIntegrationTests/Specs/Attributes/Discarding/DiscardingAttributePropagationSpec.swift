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

class DiscardingAttributePropagationSpec: ScarletSpec {
    static let describing = "a view tree with propagating discarding attributes"

    struct UserInfo: View {
        var body: some View {
            Text("Logged in as: John Scarlet")
            Text("Logout")
        }
    }

    struct Header: View {
        var body: some View {
            Row {
                Text("Main Title")

                Divider()

                UserInfo()
            }
        }
    }

    struct Footer: View {
        var body: some View {
            Image(source: "controller-icon")
            Text("P1")
        }
    }

    struct Content: View {
        var body: some View {
            Text("Loading content...")
        }
    }

    struct MainContent: View {
        var body: some View {
            Column {
                Header()
                Content()
                Footer()
            }
        }
    }

    struct Tested: TestView {
        let textColor: Color
        let grow: Float

        var body: some View {
            MainContent()
                .textColor(textColor)
                .grow(grow)
        }

        static func spec() -> Spec {
            when("the view tree is created") {
                given {
                    Tested(textColor: .orange, grow: 1.0)
                }

                then("the implementation tree is created") { result in
                    expect(result.implementation).to(equal(
                        ViewImpl("Tested") {
                            ViewImpl("MainContent", grow: 1.0) {
                                ViewImpl("Column") {
                                    ViewImpl("Header") {
                                        ViewImpl("Row") {
                                            TextImpl(text: "Main Title", textColor: .orange)

                                            ViewImpl("Divider").anyChildren()

                                            ViewImpl("UserInfo") {
                                                TextImpl(text: "Logged in as: John Scarlet", textColor: .orange)
                                                TextImpl(text: "Logout", textColor: .orange)
                                            }
                                        }
                                    }

                                    ViewImpl("Content") {
                                        TextImpl(text: "Loading content...", textColor: .orange)
                                    }

                                    ViewImpl("Footer") {
                                        ImageImpl(source: "controller-icon")
                                        TextImpl(text: "P1", textColor: .orange)
                                    }
                                }
                            }
                        }
                    ))
                }
            }

            when("no attribute change") {
                given {
                    Tested(textColor: .orange, grow: 1.0)
                    Tested(textColor: .orange, grow: 1.0)
                }

                then("the implementation tree is untouched") { result in
                    expect(result.implementation).to(equal(
                        ViewImpl("Tested") {
                            ViewImpl("MainContent", grow: 1.0) {
                                ViewImpl("Column") {
                                    ViewImpl("Header") {
                                        ViewImpl("Row") {
                                            TextImpl(text: "Main Title", textColor: .orange)

                                            ViewImpl("Divider").anyChildren()

                                            ViewImpl("UserInfo") {
                                                TextImpl(text: "Logged in as: John Scarlet", textColor: .orange)
                                                TextImpl(text: "Logout", textColor: .orange)
                                            }
                                        }
                                    }

                                    ViewImpl("Content") {
                                        TextImpl(text: "Loading content...", textColor: .orange)
                                    }

                                    ViewImpl("Footer") {
                                        ImageImpl(source: "controller-icon")
                                        TextImpl(text: "P1", textColor: .orange)
                                    }
                                }
                            }
                        }
                    ))
                }

                then("attributes are not updated on the implementation side") { result in
                    expect(result.all(TextImpl.self, expectedCount: 5)).to(allPass {
                        $0.textColorChanged == false
                    })

                    expect(result.allViews).to(allPass {
                        $0.anyAttributeChanged == false
                    })
                }
            }

            when("the nonpropagating attribute changes") {
                given {
                    Tested(textColor: .orange, grow: 1.0)
                    Tested(textColor: .orange, grow: 0.5)
                }

                then("the implementation tree is updated") { result in
                    expect(result.implementation).to(equal(
                        ViewImpl("Tested") {
                            ViewImpl("MainContent", grow: 0.5) {
                                ViewImpl("Column") {
                                    ViewImpl("Header") {
                                        ViewImpl("Row") {
                                            TextImpl(text: "Main Title", textColor: .orange)

                                            ViewImpl("Divider").anyChildren()

                                            ViewImpl("UserInfo") {
                                                TextImpl(text: "Logged in as: John Scarlet", textColor: .orange)
                                                TextImpl(text: "Logout", textColor: .orange)
                                            }
                                        }
                                    }

                                    ViewImpl("Content") {
                                        TextImpl(text: "Loading content...", textColor: .orange)
                                    }

                                    ViewImpl("Footer") {
                                        ImageImpl(source: "controller-icon")
                                        TextImpl(text: "P1", textColor: .orange)
                                    }
                                }
                            }
                        }
                    ))
                }

                then("changed attribute is updated on the implementation side") { result in
                    expect(result.testedChildren[0].attributeChanged(\.grow)).to(beTrue())
                }

                then("changed attribute is not updated on the changed view children") { result in
                    expect(result.testedChildren[0].allChildren).to(allPass {
                        $0.attributeChanged(\.grow) == false
                    })
                }

                then("unchanged attribute is not updated on the implementation side") { result in
                    expect(result.all(TextImpl.self, expectedCount: 5)).to(allPass {
                        $0.textColorChanged == false
                    })
                }
            }

            when("the propagating attribute changes") {
                given {
                    Tested(textColor: .orange, grow: 1.0)
                    Tested(textColor: .yellow, grow: 1.0)
                }

                then("the implementation tree is updated") { result in
                    expect(result.implementation).to(equal(
                        ViewImpl("Tested") {
                            ViewImpl("MainContent", grow: 1.0) {
                                ViewImpl("Column") {
                                    ViewImpl("Header") {
                                        ViewImpl("Row") {
                                            TextImpl(text: "Main Title", textColor: .yellow)

                                            ViewImpl("Divider").anyChildren()

                                            ViewImpl("UserInfo") {
                                                TextImpl(text: "Logged in as: John Scarlet", textColor: .yellow)
                                                TextImpl(text: "Logout", textColor: .yellow)
                                            }
                                        }
                                    }

                                    ViewImpl("Content") {
                                        TextImpl(text: "Loading content...", textColor: .yellow)
                                    }

                                    ViewImpl("Footer") {
                                        ImageImpl(source: "controller-icon")
                                        TextImpl(text: "P1", textColor: .yellow)
                                    }
                                }
                            }
                        }
                    ))
                }

                then("changed attribute is updated on the implementation side") { result in
                    expect(result.all(TextImpl.self, expectedCount: 5)).to(allPass {
                        $0.textColorChanged == true
                    })
                }

                then("unchanged attributes are not updated on the implementation side") { result in
                    expect(result.allViews).to(allPass {
                        $0.anyAttributeChanged == false
                    })
                }
            }

            when("both attributes changes") {
                given {
                    Tested(textColor: .orange, grow: 1.0)
                    Tested(textColor: .yellow, grow: 0.5)
                }

                then("the implementation tree is updated") { result in
                    expect(result.implementation).to(equal(
                        ViewImpl("Tested") {
                            ViewImpl("MainContent", grow: 0.5) {
                                ViewImpl("Column") {
                                    ViewImpl("Header") {
                                        ViewImpl("Row") {
                                            TextImpl(text: "Main Title", textColor: .yellow)

                                            ViewImpl("Divider").anyChildren()

                                            ViewImpl("UserInfo") {
                                                TextImpl(text: "Logged in as: John Scarlet", textColor: .yellow)
                                                TextImpl(text: "Logout", textColor: .yellow)
                                            }
                                        }
                                    }

                                    ViewImpl("Content") {
                                        TextImpl(text: "Loading content...", textColor: .yellow)
                                    }

                                    ViewImpl("Footer") {
                                        ImageImpl(source: "controller-icon")
                                        TextImpl(text: "P1", textColor: .yellow)
                                    }
                                }
                            }
                        }
                    ))
                }

                then("changed attributes are updated on the implementation side") { result in
                    expect(result.all(TextImpl.self, expectedCount: 5)).to(allPass {
                        $0.textColorChanged == true
                    })

                    expect(result.testedChildren[0].attributeChanged(\.grow)).to(beTrue())
                }

                then("changed attribute is not updated on the changed view children") { result in
                    expect(result.testedChildren[0].allChildren).to(allPass {
                        $0.attributeChanged(\.grow) == false
                    })
                }
            }
        }
    }
}
