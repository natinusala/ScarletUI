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

class AppendingAttributeMultiplePropagationSpec: ScarletSpec {
    static let describing = "a view tree with multiple propagating appending attributes"

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
        let firstDecoration: TextDecoration
        let secondDecoration: TextDecoration

        var body: some View {
            MainContent()
                .decorate(firstDecoration)
                .decorate(secondDecoration)
        }

        static func spec() -> Spec {
            when("the view tree is created") {
                given {
                    Tested(firstDecoration: .bold, secondDecoration: .strikethrough)
                }

                then("the implementation tree is created") { result in
                    expect(result.implementation).to(equal(
                        ViewImpl("Tested") {
                            ViewImpl("MainContent") {
                                ViewImpl("Column") {
                                    ViewImpl("Header") {
                                        ViewImpl("Row") {
                                            TextImpl(text: "Main Title", decorations: [.bold, .strikethrough])

                                            ViewImpl("Divider").anyChildren()

                                            ViewImpl("UserInfo") {
                                                TextImpl(text: "Logged in as: John Scarlet", decorations: [.bold, .strikethrough])
                                                TextImpl(text: "Logout", decorations: [.bold, .strikethrough])
                                            }
                                        }
                                    }

                                    ViewImpl("Content") {
                                        TextImpl(text: "Loading content...", decorations: [.bold, .strikethrough])
                                    }

                                    ViewImpl("Footer") {
                                        ImageImpl(source: "controller-icon")
                                        TextImpl(text: "P1", decorations: [.bold, .strikethrough])
                                    }
                                }
                            }
                        }
                    ))
                }
            }

            when("no attribute change") {
                given {
                    Tested(firstDecoration: .bold, secondDecoration: .strikethrough)
                    Tested(firstDecoration: .bold, secondDecoration: .strikethrough)
                }

                then("the implementation tree is untouched") { result in
                    expect(result.implementation).to(equal(
                        ViewImpl("Tested") {
                            ViewImpl("MainContent") {
                                ViewImpl("Column") {
                                    ViewImpl("Header") {
                                        ViewImpl("Row") {
                                            TextImpl(text: "Main Title", decorations: [.bold, .strikethrough])

                                            ViewImpl("Divider").anyChildren()

                                            ViewImpl("UserInfo") {
                                                TextImpl(text: "Logged in as: John Scarlet", decorations: [.bold, .strikethrough])
                                                TextImpl(text: "Logout", decorations: [.bold, .strikethrough])
                                            }
                                        }
                                    }

                                    ViewImpl("Content") {
                                        TextImpl(text: "Loading content...", decorations: [.bold, .strikethrough])
                                    }

                                    ViewImpl("Footer") {
                                        ImageImpl(source: "controller-icon")
                                        TextImpl(text: "P1", decorations: [.bold, .strikethrough])
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

            when("the first attribute changes") {
                given {
                    Tested(firstDecoration: .bold, secondDecoration: .strikethrough)
                    Tested(firstDecoration: .underlined, secondDecoration: .strikethrough)
                }

                then("the implementation tree is updated") { result in
                    expect(result.implementation).to(equal(
                        ViewImpl("Tested") {
                            ViewImpl("MainContent") {
                                ViewImpl("Column") {
                                    ViewImpl("Header") {
                                        ViewImpl("Row") {
                                            TextImpl(text: "Main Title", decorations: [.underlined, .strikethrough])

                                            ViewImpl("Divider").anyChildren()

                                            ViewImpl("UserInfo") {
                                                TextImpl(text: "Logged in as: John Scarlet", decorations: [.underlined, .strikethrough])
                                                TextImpl(text: "Logout", decorations: [.underlined, .strikethrough])
                                            }
                                        }
                                    }

                                    ViewImpl("Content") {
                                        TextImpl(text: "Loading content...", decorations: [.underlined, .strikethrough])
                                    }

                                    ViewImpl("Footer") {
                                        ImageImpl(source: "controller-icon")
                                        TextImpl(text: "P1", decorations: [.underlined, .strikethrough])
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

            when("the second attribute changes") {
                given {
                    Tested(firstDecoration: .bold, secondDecoration: .strikethrough)
                    Tested(firstDecoration: .bold, secondDecoration: .underlined)
                }

                then("the implementation tree is updated") { result in
                    expect(result.implementation).to(equal(
                        ViewImpl("Tested") {
                            ViewImpl("MainContent") {
                                ViewImpl("Column") {
                                    ViewImpl("Header") {
                                        ViewImpl("Row") {
                                            TextImpl(text: "Main Title", decorations: [.bold, .underlined])

                                            ViewImpl("Divider").anyChildren()

                                            ViewImpl("UserInfo") {
                                                TextImpl(text: "Logged in as: John Scarlet", decorations: [.bold, .underlined])
                                                TextImpl(text: "Logout", decorations: [.bold, .underlined])
                                            }
                                        }
                                    }

                                    ViewImpl("Content") {
                                        TextImpl(text: "Loading content...", decorations: [.bold, .underlined])
                                    }

                                    ViewImpl("Footer") {
                                        ImageImpl(source: "controller-icon")
                                        TextImpl(text: "P1", decorations: [.bold, .underlined])
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

            when("both attributes change") {
                given {
                    Tested(firstDecoration: .bold, secondDecoration: .strikethrough)
                    Tested(firstDecoration: .strikethrough, secondDecoration: .underlined)
                }

                then("the implementation tree is updated") { result in
                    expect(result.implementation).to(equal(
                        ViewImpl("Tested") {
                            ViewImpl("MainContent") {
                                ViewImpl("Column") {
                                    ViewImpl("Header") {
                                        ViewImpl("Row") {
                                            TextImpl(text: "Main Title", decorations: [.strikethrough, .underlined])

                                            ViewImpl("Divider").anyChildren()

                                            ViewImpl("UserInfo") {
                                                TextImpl(text: "Logged in as: John Scarlet", decorations: [.strikethrough, .underlined])
                                                TextImpl(text: "Logout", decorations: [.strikethrough, .underlined])
                                            }
                                        }
                                    }

                                    ViewImpl("Content") {
                                        TextImpl(text: "Loading content...", decorations: [.strikethrough, .underlined])
                                    }

                                    ViewImpl("Footer") {
                                        ImageImpl(source: "controller-icon")
                                        TextImpl(text: "P1", decorations: [.strikethrough, .underlined])
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
