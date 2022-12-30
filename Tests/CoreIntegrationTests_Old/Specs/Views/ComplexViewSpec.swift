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

class ComplexViewSpec: ScarletCoreSpec {
    static let describing = "a view with a little bit of everything"

     struct Tested: TestView {
        let detailed: Bool

        var body: some View {
            Column {
                // Header
                Row {
                    Image(source: "mainLogo.png")
                    Text(detailed ? "App Title (debug)" : "App Title")

                    Divider()

                    Text("Logged in as: FooBarBaz")

                    if detailed {
                        Divider()

                        Text("Unread messages: 7")
                        Text("Update available!")
                    }

                    Divider()

                    Text("X: Close")
                }

                Divider()

                // Body
                Row {
                    Column {
                        Text("Unread (7)")
                        Text("Sent")

                        if !detailed {
                            Divider()

                            Text("Enable detailed mode to see spam")
                        }

                        Divider()

                        Text("Settings")
                    }
                }

                Divider()

                // Footer
                Row {
                    Text(detailed ? "Controller 1: Keyboard / Mouse" : "Keyboard / Mouse")
                    Text(detailed ?  "P1 A: OK" : "A: OK")
                    Text(detailed ?  "P1 B: Back" : "B: Back")
                }

                // Debug bar
                if detailed {
                    Row {
                        Text("Debug bar")
                        Text("Memory: 74mB")
                        Text("CPU Usage: 2%")
                        Text("GPU Usage: 1%")
                    }
                }
            }
        }

        static func spec() -> Specs {
            when("the view is created with optionals on") {
                given {
                    Tested(detailed: true)
                }

                then("implementation is created") { result in
                    expect(result.implementation).to(equal(
                        ViewImpl("Tested") {
                            ViewImpl("Column") {
                                // Header
                                ViewImpl("Row") {
                                    ImageImpl(source: "mainLogo.png")
                                    TextImpl(text: "App Title (debug)")

                                    ViewImpl("Divider")

                                    TextImpl(text: "Logged in as: FooBarBaz")

                                    ViewImpl("Divider")

                                    TextImpl(text: "Unread messages: 7")
                                    TextImpl(text: "Update available!")

                                    ViewImpl("Divider")

                                    TextImpl(text: "X: Close")
                                }

                                ViewImpl("Divider")

                                // Body
                                ViewImpl("Row") {
                                    ViewImpl("Column") {
                                        TextImpl(text: "Unread (7)")
                                        TextImpl(text: "Sent")

                                        ViewImpl("Divider")

                                        TextImpl(text: "Settings")
                                    }
                                }

                                ViewImpl("Divider")

                                // Footer
                                ViewImpl("Row") {
                                    TextImpl(text: "Controller 1: Keyboard / Mouse")
                                    TextImpl(text: "P1 A: OK")
                                    TextImpl(text: "P1 B: Back")
                                }

                                ViewImpl("Row") {
                                    TextImpl(text: "Debug bar")
                                    TextImpl(text: "Memory: 74mB")
                                    TextImpl(text: "CPU Usage: 2%")
                                    TextImpl(text: "GPU Usage: 1%")
                                }
                            }
                        }
                    ))
                }
            }

            when("the view is created with optionals off") {
                given {
                    Tested(detailed: false)
                }

                then("implementation is created") { result in
                    expect(result.implementation).to(equal(
                        ViewImpl("Tested") {
                            ViewImpl("Column") {
                                // Header
                                ViewImpl("Row") {
                                    ImageImpl(source: "mainLogo.png")
                                    TextImpl(text: "App Title")

                                    ViewImpl("Divider")

                                    TextImpl(text: "Logged in as: FooBarBaz")

                                    ViewImpl("Divider")

                                    TextImpl(text: "X: Close")
                                }

                                ViewImpl("Divider")

                                // Body
                                ViewImpl("Row") {
                                    ViewImpl("Column") {
                                        TextImpl(text: "Unread (7)")
                                        TextImpl(text: "Sent")

                                        ViewImpl("Divider")

                                        TextImpl(text: "Enable detailed mode to see spam")

                                        ViewImpl("Divider")

                                        TextImpl(text: "Settings")
                                    }
                                }

                                ViewImpl("Divider")

                                // Footer
                                ViewImpl("Row") {
                                    TextImpl(text: "Keyboard / Mouse")
                                    TextImpl(text: "A: OK")
                                    TextImpl(text: "B: Back")
                                }
                            }
                        }
                    ))
                }
            }

            when("optionals are flipped to false") {
                given {
                    Tested(detailed: true)
                    Tested(detailed: false)
                }

                then("implementation is created") { result in
                    expect(result.implementation).to(equal(
                        ViewImpl("Tested") {
                            ViewImpl("Column") {
                                // Header
                                ViewImpl("Row") {
                                    ImageImpl(source: "mainLogo.png")
                                    TextImpl(text: "App Title")

                                    ViewImpl("Divider")

                                    TextImpl(text: "Logged in as: FooBarBaz")

                                    ViewImpl("Divider")

                                    TextImpl(text: "X: Close")
                                }

                                ViewImpl("Divider")

                                // Body
                                ViewImpl("Row") {
                                    ViewImpl("Column") {
                                        TextImpl(text: "Unread (7)")
                                        TextImpl(text: "Sent")

                                        ViewImpl("Divider")

                                        TextImpl(text: "Enable detailed mode to see spam")

                                        ViewImpl("Divider")

                                        TextImpl(text: "Settings")
                                    }
                                }

                                ViewImpl("Divider")

                                // Footer
                                ViewImpl("Row") {
                                    TextImpl(text: "Keyboard / Mouse")
                                    TextImpl(text: "A: OK")
                                    TextImpl(text: "B: Back")
                                }
                            }
                        }
                    ))
                }
            }

            when("optionals are flipped to true") {
                given {
                    Tested(detailed: false)
                    Tested(detailed: true)
                }

                then("implementation is created") { result in
                    expect(result.implementation).to(equal(
                        ViewImpl("Tested") {
                            ViewImpl("Column") {
                                // Header
                                ViewImpl("Row") {
                                    ImageImpl(source: "mainLogo.png")
                                    TextImpl(text: "App Title (debug)")

                                    ViewImpl("Divider")

                                    TextImpl(text: "Logged in as: FooBarBaz")

                                    ViewImpl("Divider")

                                    TextImpl(text: "Unread messages: 7")
                                    TextImpl(text: "Update available!")

                                    ViewImpl("Divider")

                                    TextImpl(text: "X: Close")
                                }

                                ViewImpl("Divider")

                                // Body
                                ViewImpl("Row") {
                                    ViewImpl("Column") {
                                        TextImpl(text: "Unread (7)")
                                        TextImpl(text: "Sent")

                                        ViewImpl("Divider")

                                        TextImpl(text: "Settings")
                                    }
                                }

                                ViewImpl("Divider")

                                // Footer
                                ViewImpl("Row") {
                                    TextImpl(text: "Controller 1: Keyboard / Mouse")
                                    TextImpl(text: "P1 A: OK")
                                    TextImpl(text: "P1 B: Back")
                                }

                                ViewImpl("Row") {
                                    TextImpl(text: "Debug bar")
                                    TextImpl(text: "Memory: 74mB")
                                    TextImpl(text: "CPU Usage: 2%")
                                    TextImpl(text: "GPU Usage: 1%")
                                }
                            }
                        }
                    ))
                }
            }
        }
    }
}
