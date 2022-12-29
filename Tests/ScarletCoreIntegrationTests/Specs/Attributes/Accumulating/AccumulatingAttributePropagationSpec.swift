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

class AccumulatingAttributePropagationSpec: ScarletSpec {
    static let describing = "a view tree with one propagating accumulating attribute"

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

                then("the implementation tree is created") { result in
                    expect(result.implementation).to(equal(
                        ViewImpl("Tested") {
                            ViewImpl("MainContent") {
                                ViewImpl("Column") {
                                    ViewImpl("Header") {
                                        ViewImpl("Row") {
                                            TextImpl(text: "Main Title", decorations: [.bold])

                                            ViewImpl("Divider").anyChildren()

                                            ViewImpl("UserInfo") {
                                                TextImpl(text: "Logged in as: John Scarlet", decorations: [.bold])
                                                TextImpl(text: "Logout", decorations: [.bold])
                                            }
                                        }
                                    }

                                    ViewImpl("Content") {
                                        TextImpl(text: "Loading content...", decorations: [.bold])
                                    }

                                    ViewImpl("Footer") {
                                        ImageImpl(source: "controller-icon")
                                        TextImpl(text: "P1", decorations: [.bold])
                                    }
                                }
                            }
                        }
                    ))
                }
            }

            when("no attribute change") {
                given {
                    Tested(textDecoration: .bold)
                    Tested(textDecoration: .bold)
                }

                then("the implementation tree is untouched") { result in
                    expect(result.implementation).to(equal(
                        ViewImpl("Tested") {
                            ViewImpl("MainContent") {
                                ViewImpl("Column") {
                                    ViewImpl("Header") {
                                        ViewImpl("Row") {
                                            TextImpl(text: "Main Title", decorations: [.bold])

                                            ViewImpl("Divider").anyChildren()

                                            ViewImpl("UserInfo") {
                                                TextImpl(text: "Logged in as: John Scarlet", decorations: [.bold])
                                                TextImpl(text: "Logout", decorations: [.bold])
                                            }
                                        }
                                    }

                                    ViewImpl("Content") {
                                        TextImpl(text: "Loading content...", decorations: [.bold])
                                    }

                                    ViewImpl("Footer") {
                                        ImageImpl(source: "controller-icon")
                                        TextImpl(text: "P1", decorations: [.bold])
                                    }
                                }
                            }
                        }
                    ))
                }

                then("attributes are not updated on the implementation side") { result in
                    expect(result.all(TextImpl.self, expectedCount: 5)).to(allPass {
                        $0.decorationsChanged == false
                    })
                }
            }

            when("the attribute changes") {
                given {
                    Tested(textDecoration: .bold)
                    Tested(textDecoration: .italic)
                }

                then("the implementation tree is updated") { result in
                    expect(result.implementation).to(equal(
                        ViewImpl("Tested") {
                            ViewImpl("MainContent") {
                                ViewImpl("Column") {
                                    ViewImpl("Header") {
                                        ViewImpl("Row") {
                                            TextImpl(text: "Main Title", decorations: [.italic])

                                            ViewImpl("Divider").anyChildren()

                                            ViewImpl("UserInfo") {
                                                TextImpl(text: "Logged in as: John Scarlet", decorations: [.italic])
                                                TextImpl(text: "Logout", decorations: [.italic])
                                            }
                                        }
                                    }

                                    ViewImpl("Content") {
                                        TextImpl(text: "Loading content...", decorations: [.italic])
                                    }

                                    ViewImpl("Footer") {
                                        ImageImpl(source: "controller-icon")
                                        TextImpl(text: "P1", decorations: [.italic])
                                    }
                                }
                            }
                        }
                    ))
                }

                then("attribute is updated on the implementation side") { result in
                    expect(result.all(TextImpl.self, expectedCount: 5)).to(allPass {
                        $0.decorationsChanged == true
                    })
                }
            }
        }
    }
}
