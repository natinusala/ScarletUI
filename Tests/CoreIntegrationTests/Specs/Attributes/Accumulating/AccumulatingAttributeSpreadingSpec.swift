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

class AccumulatingAttributeSpreadingSpec: ScarletCoreSpec {
    static let describing = "a view tree with one spreading accumulating attribute"

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
        let textDecoration: TextDecoration

        var body: some View {
            MainContent()
                .decorate(textDecoration)
        }

        static func spec() -> Spec {
            when("the view tree is created") {
                given {
                    Tested(textDecoration: .bold)
                }

                then("the target tree is created") { result in
                    expect(result.target).to(equal(
                        ViewTarget("Tested") {
                            ViewTarget("MainContent") {
                                ViewTarget("Column") {
                                    ViewTarget("Header") {
                                        ViewTarget("Row") {
                                            TextTarget(text: "Main Title", decorations: [.bold])

                                            ViewTarget("Divider").anyChildren()

                                            ViewTarget("UserInfo") {
                                                TextTarget(text: "Logged in as: John Scarlet", decorations: [.bold])
                                                TextTarget(text: "Logout", decorations: [.bold])
                                            }
                                        }
                                    }

                                    ViewTarget("Content") {
                                        TextTarget(text: "Loading content...", decorations: [.bold])
                                    }

                                    ViewTarget("Footer") {
                                        ImageTarget(source: "controller-icon")
                                        TextTarget(text: "P1", decorations: [.bold])
                                    }
                                }
                            }
                        }
                    ))
                }

                then("view body is not called") { result in
                    expect(result.bodyCalled(of: MainContent.self)).to(beFalse())
                }
            }

            when("no attribute change") {
                given {
                    Tested(textDecoration: .bold)
                    Tested(textDecoration: .bold)
                }

                then("the target tree is untouched") { result in
                    expect(result.target).to(equal(
                        ViewTarget("Tested") {
                            ViewTarget("MainContent") {
                                ViewTarget("Column") {
                                    ViewTarget("Header") {
                                        ViewTarget("Row") {
                                            TextTarget(text: "Main Title", decorations: [.bold])

                                            ViewTarget("Divider").anyChildren()

                                            ViewTarget("UserInfo") {
                                                TextTarget(text: "Logged in as: John Scarlet", decorations: [.bold])
                                                TextTarget(text: "Logout", decorations: [.bold])
                                            }
                                        }
                                    }

                                    ViewTarget("Content") {
                                        TextTarget(text: "Loading content...", decorations: [.bold])
                                    }

                                    ViewTarget("Footer") {
                                        ImageTarget(source: "controller-icon")
                                        TextTarget(text: "P1", decorations: [.bold])
                                    }
                                }
                            }
                        }
                    ))
                }

                then("attributes are not updated on the target side") { result in
                    expect(result.all(TextTarget.self, expectedCount: 5)).to(allPass {
                        $0.decorationsChanged == false
                    })
                }

                then("view body is not called") { result in
                    expect(result.bodyCalled(of: MainContent.self)).to(beFalse())
                }
            }

            when("the attribute changes") {
                given {
                    Tested(textDecoration: .bold)
                    Tested(textDecoration: .italic)
                }

                then("the target tree is updated") { result in
                    expect(result.target).to(equal(
                        ViewTarget("Tested") {
                            ViewTarget("MainContent") {
                                ViewTarget("Column") {
                                    ViewTarget("Header") {
                                        ViewTarget("Row") {
                                            TextTarget(text: "Main Title", decorations: [.italic])

                                            ViewTarget("Divider").anyChildren()

                                            ViewTarget("UserInfo") {
                                                TextTarget(text: "Logged in as: John Scarlet", decorations: [.italic])
                                                TextTarget(text: "Logout", decorations: [.italic])
                                            }
                                        }
                                    }

                                    ViewTarget("Content") {
                                        TextTarget(text: "Loading content...", decorations: [.italic])
                                    }

                                    ViewTarget("Footer") {
                                        ImageTarget(source: "controller-icon")
                                        TextTarget(text: "P1", decorations: [.italic])
                                    }
                                }
                            }
                        }
                    ))
                }

                then("attribute is updated on the target side") { result in
                    expect(result.all(TextTarget.self, expectedCount: 5)).to(allPass {
                        $0.decorationsChanged == true
                    })
                }

                then("view body is not called") { result in
                    expect(result.bodyCalled(of: MainContent.self)).to(beFalse())
                }
            }
        }
    }
}
