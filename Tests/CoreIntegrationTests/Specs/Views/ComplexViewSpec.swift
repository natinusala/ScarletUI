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

        static func spec() -> Spec {
            when("the view is created with optionals on") {
                given {
                    Tested(detailed: true)
                }

                then("target is created") { result in
                    expect(result.target).to(equal(
                        ViewTarget("Tested") {
                            ViewTarget("Column") {
                                // Header
                                ViewTarget("Row") {
                                    ImageTarget(source: "mainLogo.png")
                                    TextTarget(text: "App Title (debug)")

                                    ViewTarget("Divider")

                                    TextTarget(text: "Logged in as: FooBarBaz")

                                    ViewTarget("Divider")

                                    TextTarget(text: "Unread messages: 7")
                                    TextTarget(text: "Update available!")

                                    ViewTarget("Divider")

                                    TextTarget(text: "X: Close")
                                }

                                ViewTarget("Divider")

                                // Body
                                ViewTarget("Row") {
                                    ViewTarget("Column") {
                                        TextTarget(text: "Unread (7)")
                                        TextTarget(text: "Sent")

                                        ViewTarget("Divider")

                                        TextTarget(text: "Settings")
                                    }
                                }

                                ViewTarget("Divider")

                                // Footer
                                ViewTarget("Row") {
                                    TextTarget(text: "Controller 1: Keyboard / Mouse")
                                    TextTarget(text: "P1 A: OK")
                                    TextTarget(text: "P1 B: Back")
                                }

                                ViewTarget("Row") {
                                    TextTarget(text: "Debug bar")
                                    TextTarget(text: "Memory: 74mB")
                                    TextTarget(text: "CPU Usage: 2%")
                                    TextTarget(text: "GPU Usage: 1%")
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

                then("target is created") { result in
                    expect(result.target).to(equal(
                        ViewTarget("Tested") {
                            ViewTarget("Column") {
                                // Header
                                ViewTarget("Row") {
                                    ImageTarget(source: "mainLogo.png")
                                    TextTarget(text: "App Title")

                                    ViewTarget("Divider")

                                    TextTarget(text: "Logged in as: FooBarBaz")

                                    ViewTarget("Divider")

                                    TextTarget(text: "X: Close")
                                }

                                ViewTarget("Divider")

                                // Body
                                ViewTarget("Row") {
                                    ViewTarget("Column") {
                                        TextTarget(text: "Unread (7)")
                                        TextTarget(text: "Sent")

                                        ViewTarget("Divider")

                                        TextTarget(text: "Enable detailed mode to see spam")

                                        ViewTarget("Divider")

                                        TextTarget(text: "Settings")
                                    }
                                }

                                ViewTarget("Divider")

                                // Footer
                                ViewTarget("Row") {
                                    TextTarget(text: "Keyboard / Mouse")
                                    TextTarget(text: "A: OK")
                                    TextTarget(text: "B: Back")
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

                then("target is created") { result in
                    expect(result.target).to(equal(
                        ViewTarget("Tested") {
                            ViewTarget("Column") {
                                // Header
                                ViewTarget("Row") {
                                    ImageTarget(source: "mainLogo.png")
                                    TextTarget(text: "App Title")

                                    ViewTarget("Divider")

                                    TextTarget(text: "Logged in as: FooBarBaz")

                                    ViewTarget("Divider")

                                    TextTarget(text: "X: Close")
                                }

                                ViewTarget("Divider")

                                // Body
                                ViewTarget("Row") {
                                    ViewTarget("Column") {
                                        TextTarget(text: "Unread (7)")
                                        TextTarget(text: "Sent")

                                        ViewTarget("Divider")

                                        TextTarget(text: "Enable detailed mode to see spam")

                                        ViewTarget("Divider")

                                        TextTarget(text: "Settings")
                                    }
                                }

                                ViewTarget("Divider")

                                // Footer
                                ViewTarget("Row") {
                                    TextTarget(text: "Keyboard / Mouse")
                                    TextTarget(text: "A: OK")
                                    TextTarget(text: "B: Back")
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

                then("target is created") { result in
                    expect(result.target).to(equal(
                        ViewTarget("Tested") {
                            ViewTarget("Column") {
                                // Header
                                ViewTarget("Row") {
                                    ImageTarget(source: "mainLogo.png")
                                    TextTarget(text: "App Title (debug)")

                                    ViewTarget("Divider")

                                    TextTarget(text: "Logged in as: FooBarBaz")

                                    ViewTarget("Divider")

                                    TextTarget(text: "Unread messages: 7")
                                    TextTarget(text: "Update available!")

                                    ViewTarget("Divider")

                                    TextTarget(text: "X: Close")
                                }

                                ViewTarget("Divider")

                                // Body
                                ViewTarget("Row") {
                                    ViewTarget("Column") {
                                        TextTarget(text: "Unread (7)")
                                        TextTarget(text: "Sent")

                                        ViewTarget("Divider")

                                        TextTarget(text: "Settings")
                                    }
                                }

                                ViewTarget("Divider")

                                // Footer
                                ViewTarget("Row") {
                                    TextTarget(text: "Controller 1: Keyboard / Mouse")
                                    TextTarget(text: "P1 A: OK")
                                    TextTarget(text: "P1 B: Back")
                                }

                                ViewTarget("Row") {
                                    TextTarget(text: "Debug bar")
                                    TextTarget(text: "Memory: 74mB")
                                    TextTarget(text: "CPU Usage: 2%")
                                    TextTarget(text: "GPU Usage: 1%")
                                }
                            }
                        }
                    ))
                }
            }
        }
    }
}
