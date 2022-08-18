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

// Ported from a fuzzer generayed test case
class ConsecutiveConditionalViewSpecDefinition: SpecDefinition {
    static let describing = "a view with two consecutive conditionals"

    struct Picture: View {
        let variable0: Int

        var body: some View {
            Image(source: "https://pictures.com/picture\(variable0).jpg")
        }
    }

    struct Tested: TestView {
        let flip0: Bool
        let flip1: Bool
        let variable0: Int
        let variable1: Int
        let variable2: Int
        let variable3: Int
        let variable4: Int

        var body: some View {
            Row {
                Row {
                    // 0
                    if flip0 {
                        Text("Mouse")
                    } else {
                        Text("Doug")
                    }

                    // 1
                    if flip0 {
                        Text("Cat")
                    } else if flip0 {
                        Text("Apple")
                    } else if flip1 {
                        Image(source: "https://pictures.com/Switch.jpg")
                    } else if flip1 {
                        Image(source: "https://pictures.com/picture\(variable0).jpg")
                    }

                    // 2
                    Column {
                        Picture(variable0: variable1)
                        Text("variable1=\(variable1)")
                    }
                    // 3
                    Picture(variable0: 91)

                    // 4
                    Text("variable0=\(variable0)")

                    // 5
                    if flip1 {
                        Text("Chocolate")
                    } else if flip0 {
                        Text("variable1=\(variable1)")
                    } else if flip1 {
                        Text("variable1=\(variable1)")
                    }

                    // 6
                    Row {
                        Text("Pear")
                        Text("variable2=\(variable2)")
                        Picture(variable0: variable3)
                        Picture(variable0: variable1)
                    }

                    // 7
                    Image(source: "https://pictures.com/picture\(variable4).jpg")
                }
            }
        }

        static func spec() -> Specs {
            when("the view is created") {
                given {
                    Tested(flip0: false, flip1: false, variable0: 42, variable1: 227, variable2: 28, variable3: 165, variable4: 97)
                }

                then("implementation is created") { result in
                    expect(result.implementation).to(equal(
                        ViewImpl("Tested") {
                            ViewImpl("Row") {
                                ViewImpl("Row") {
                                    // 0
                                    TextImpl(text: "Doug")

                                    // 1 is removed

                                    // 2
                                    ViewImpl("Column") {
                                        ViewImpl("Picture") {
                                            ImageImpl(source: "https://pictures.com/picture227.jpg")
                                        }

                                        TextImpl(text: "variable1=227")
                                    }

                                    // 3
                                    ViewImpl("Picture") {
                                        ImageImpl(source: "https://pictures.com/picture91.jpg")
                                    }

                                    // 4
                                    TextImpl(text: "variable0=42")

                                    // 5 is removed

                                    // 6
                                    ViewImpl("Row") {
                                        TextImpl(text: "Pear")
                                        TextImpl(text: "variable2=28")

                                        ViewImpl("Picture") {
                                            ImageImpl(source: "https://pictures.com/picture165.jpg")
                                        }

                                        ViewImpl("Picture") {
                                            ImageImpl(source: "https://pictures.com/picture227.jpg")
                                        }
                                    }

                                    // 7
                                    ImageImpl(source: "https://pictures.com/picture97.jpg")
                                }
                            }
                        }
                    ))
                }
            }

            when("the view is updated") {
                given {
                    Tested(flip0: false, flip1: false, variable0: 42, variable1: 227, variable2: 28, variable3: 165, variable4: 97)
                    Tested(flip0: true, flip1: true, variable0: 149, variable1: 195, variable2: 59, variable3: 101, variable4: 3)
                }

                then("implementation is updated") { result in
                    expect(result.implementation).to(equal(
                        ViewImpl("Tested") {
                            ViewImpl("Row") {
                                ViewImpl("Row") {
                                    // 0
                                    TextImpl(text: "Mouse")

                                    // 1
                                    TextImpl(text: "Cat")

                                    // 2
                                    ViewImpl("Column") {
                                        ViewImpl("Picture") {
                                            ImageImpl(source: "https://pictures.com/picture195.jpg")
                                        }

                                        TextImpl(text: "variable1=195")
                                    }

                                    // 3
                                    ViewImpl("Picture") {
                                        ImageImpl(source: "https://pictures.com/picture91.jpg")
                                    }

                                    // 4
                                    TextImpl(text: "variable0=149")

                                    // 5
                                    TextImpl(text: "Chocolate")

                                    // 6
                                    ViewImpl("Row") {
                                        TextImpl(text: "Pear")
                                        TextImpl(text: "variable2=59")

                                        ViewImpl("Picture") {
                                            ImageImpl(source: "https://pictures.com/picture101.jpg")
                                        }

                                        ViewImpl("Picture") {
                                            ImageImpl(source: "https://pictures.com/picture195.jpg")
                                        }
                                    }

                                    // 7
                                    ImageImpl(source: "https://pictures.com/picture3.jpg")
                                }
                            }
                        }
                    ))
                }
            }
        }
    }
}

typealias ConsecutiveConditionalViewSpec = ScarletSpec<ConsecutiveConditionalViewSpecDefinition>
