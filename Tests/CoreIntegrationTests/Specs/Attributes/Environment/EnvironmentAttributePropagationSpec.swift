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

class EnvironmentAttributePropagationSpec: ScarletCoreSpec {
    static let describing = "a view tree with environment attributes"

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

                then("the target tree is created") { result in
                    expect(result.target).to(equal(
                        ViewTarget("Tested") {
                            ViewTarget("MainContent", grow: 1.0) {
                                ViewTarget("Column") {
                                    ViewTarget("Header") {
                                        ViewTarget("Row") {
                                            TextTarget(text: "Main Title", textColor: .orange)

                                            ViewTarget("Divider").anyChildren()

                                            ViewTarget("UserInfo") {
                                                TextTarget(text: "Logged in as: John Scarlet", textColor: .orange)
                                                TextTarget(text: "Logout", textColor: .orange)
                                            }
                                        }
                                    }

                                    ViewTarget("Content") {
                                        TextTarget(text: "Loading content...", textColor: .orange)
                                    }

                                    ViewTarget("Footer") {
                                        ImageTarget(source: "controller-icon")
                                        TextTarget(text: "P1", textColor: .orange)
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

                then("the target tree is untouched") { result in
                    expect(result.target).to(equal(
                        ViewTarget("Tested") {
                            ViewTarget("MainContent", grow: 1.0) {
                                ViewTarget("Column") {
                                    ViewTarget("Header") {
                                        ViewTarget("Row") {
                                            TextTarget(text: "Main Title", textColor: .orange)

                                            ViewTarget("Divider").anyChildren()

                                            ViewTarget("UserInfo") {
                                                TextTarget(text: "Logged in as: John Scarlet", textColor: .orange)
                                                TextTarget(text: "Logout", textColor: .orange)
                                            }
                                        }
                                    }

                                    ViewTarget("Content") {
                                        TextTarget(text: "Loading content...", textColor: .orange)
                                    }

                                    ViewTarget("Footer") {
                                        ImageTarget(source: "controller-icon")
                                        TextTarget(text: "P1", textColor: .orange)
                                    }
                                }
                            }
                        }
                    ))
                }

                then("attributes are not updated on the target side") { result in
                    expect(result.all(TextTarget.self, expectedCount: 5)).to(allPass {
                        $0.textColorChanged == false
                    })

                    expect(result.allViews).to(allPass {
                        $0.anyAttributeChanged == false
                    })
                }

                then("views bodies are not called") { result in
                    expect(result.bodyCalled(of: UserInfo.self)).to(beFalse())
                    expect(result.bodyCalled(of: Header.self)).to(beFalse())
                    expect(result.bodyCalled(of: Footer.self)).to(beFalse())
                    expect(result.bodyCalled(of: Content.self)).to(beFalse())
                    expect(result.bodyCalled(of: MainContent.self)).to(beFalse())
                }
            }

            when("the nonpropagating attribute changes") {
                given {
                    Tested(textColor: .orange, grow: 1.0)
                    Tested(textColor: .orange, grow: 0.5)
                }

                then("the target tree is updated") { result in
                    expect(result.target).to(equal(
                        ViewTarget("Tested") {
                            ViewTarget("MainContent", grow: 0.5) {
                                ViewTarget("Column") {
                                    ViewTarget("Header") {
                                        ViewTarget("Row") {
                                            TextTarget(text: "Main Title", textColor: .orange)

                                            ViewTarget("Divider").anyChildren()

                                            ViewTarget("UserInfo") {
                                                TextTarget(text: "Logged in as: John Scarlet", textColor: .orange)
                                                TextTarget(text: "Logout", textColor: .orange)
                                            }
                                        }
                                    }

                                    ViewTarget("Content") {
                                        TextTarget(text: "Loading content...", textColor: .orange)
                                    }

                                    ViewTarget("Footer") {
                                        ImageTarget(source: "controller-icon")
                                        TextTarget(text: "P1", textColor: .orange)
                                    }
                                }
                            }
                        }
                    ))
                }

                then("changed attribute is updated on the target side") { result in
                    expect(result.testedChildren[0].attributeChanged(\.grow)).to(beTrue())
                }

                then("changed attribute is not updated on the changed view children") { result in
                    expect(result.testedChildren[0].allChildren).to(allPass {
                        $0.attributeChanged(\.grow) == false
                    })
                }

                then("unchanged attribute is not updated on the target side") { result in
                    expect(result.all(TextTarget.self, expectedCount: 5)).to(allPass {
                        $0.textColorChanged == false
                    })
                }

                then("views bodies are not called") { result in
                    expect(result.bodyCalled(of: UserInfo.self)).to(beFalse())
                    expect(result.bodyCalled(of: Header.self)).to(beFalse())
                    expect(result.bodyCalled(of: Footer.self)).to(beFalse())
                    expect(result.bodyCalled(of: Content.self)).to(beFalse())
                    expect(result.bodyCalled(of: MainContent.self)).to(beFalse())
                }
            }

            when("the propagating attribute changes") {
                given {
                    Tested(textColor: .orange, grow: 1.0)
                    Tested(textColor: .yellow, grow: 1.0)
                }

                then("the target tree is updated") { result in
                    expect(result.target).to(equal(
                        ViewTarget("Tested") {
                            ViewTarget("MainContent", grow: 1.0) {
                                ViewTarget("Column") {
                                    ViewTarget("Header") {
                                        ViewTarget("Row") {
                                            TextTarget(text: "Main Title", textColor: .yellow)

                                            ViewTarget("Divider").anyChildren()

                                            ViewTarget("UserInfo") {
                                                TextTarget(text: "Logged in as: John Scarlet", textColor: .yellow)
                                                TextTarget(text: "Logout", textColor: .yellow)
                                            }
                                        }
                                    }

                                    ViewTarget("Content") {
                                        TextTarget(text: "Loading content...", textColor: .yellow)
                                    }

                                    ViewTarget("Footer") {
                                        ImageTarget(source: "controller-icon")
                                        TextTarget(text: "P1", textColor: .yellow)
                                    }
                                }
                            }
                        }
                    ))
                }

                then("changed attribute is updated on the target side") { result in
                    expect(result.all(TextTarget.self, expectedCount: 5)).to(allPass {
                        $0.textColorChanged == true
                    })
                }

                then("unchanged attributes are not updated on the target side") { result in
                    expect(result.allViews).to(allPass {
                        $0.anyAttributeChanged == false
                    })
                }

                then("views bodies are not called") { result in
                    expect(result.bodyCalled(of: UserInfo.self)).to(beFalse())
                    expect(result.bodyCalled(of: Header.self)).to(beFalse())
                    expect(result.bodyCalled(of: Footer.self)).to(beFalse())
                    expect(result.bodyCalled(of: Content.self)).to(beFalse())
                    expect(result.bodyCalled(of: MainContent.self)).to(beFalse())
                }
            }

            when("both attributes changes") {
                given {
                    Tested(textColor: .orange, grow: 1.0)
                    Tested(textColor: .yellow, grow: 0.5)
                }

                then("the target tree is updated") { result in
                    expect(result.target).to(equal(
                        ViewTarget("Tested") {
                            ViewTarget("MainContent", grow: 0.5) {
                                ViewTarget("Column") {
                                    ViewTarget("Header") {
                                        ViewTarget("Row") {
                                            TextTarget(text: "Main Title", textColor: .yellow)

                                            ViewTarget("Divider").anyChildren()

                                            ViewTarget("UserInfo") {
                                                TextTarget(text: "Logged in as: John Scarlet", textColor: .yellow)
                                                TextTarget(text: "Logout", textColor: .yellow)
                                            }
                                        }
                                    }

                                    ViewTarget("Content") {
                                        TextTarget(text: "Loading content...", textColor: .yellow)
                                    }

                                    ViewTarget("Footer") {
                                        ImageTarget(source: "controller-icon")
                                        TextTarget(text: "P1", textColor: .yellow)
                                    }
                                }
                            }
                        }
                    ))
                }

                then("changed attributes are updated on the target side") { result in
                    expect(result.all(TextTarget.self, expectedCount: 5)).to(allPass {
                        $0.textColorChanged == true
                    })

                    expect(result.testedChildren[0].attributeChanged(\.grow)).to(beTrue())
                }

                then("changed attribute is not updated on the changed view children") { result in
                    expect(result.testedChildren[0].allChildren).to(allPass {
                        $0.attributeChanged(\.grow) == false
                    })
                }

                then("views bodies are not called") { result in
                    expect(result.bodyCalled(of: UserInfo.self)).to(beFalse())
                    expect(result.bodyCalled(of: Header.self)).to(beFalse())
                    expect(result.bodyCalled(of: Footer.self)).to(beFalse())
                    expect(result.bodyCalled(of: Content.self)).to(beFalse())
                    expect(result.bodyCalled(of: MainContent.self)).to(beFalse())
                }
            }
        }
    }
}
