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

class NestedOptionalViewSpec: ScarletCoreSpec {
    static let describing = "a view with nested optionals"

    struct Tested: TestView {
        let fillColumn = true
        let full: Bool

        var body: some View {
            Column {
                if fillColumn {
                    Text("Text 1")
                    Text("Text 2")

                    if full {
                        Text("Text 3")
                        Text("Text 4")
                    }

                    Text("Last text")
                }
            }
        }

        static func spec() -> Spec {
            when("the view is created with the nested optional off") {
                given {
                    Tested(full: false)
                }

                then("implementation is created") { result in
                    expect(result.implementation).to(equal(
                        ViewImpl("Tested") {
                            ViewImpl("Column") {
                                TextImpl(text: "Text 1")
                                TextImpl(text: "Text 2")

                                TextImpl(text: "Last text")
                            }
                        }
                    ))
                }
            }

            when("the view is created with the nested optional on") {
                given {
                    Tested(full: true)
                }

                then("implementation is created") { result in
                    expect(result.implementation).to(equal(
                        ViewImpl("Tested") {
                            ViewImpl("Column") {
                                TextImpl(text: "Text 1")
                                TextImpl(text: "Text 2")

                                TextImpl(text: "Text 3")
                                TextImpl(text: "Text 4")

                                TextImpl(text: "Last text")
                            }
                        }
                    ))
                }
            }

            when("the optional is flipped to off") {
                given {
                    Tested(full: true)
                    Tested(full: false)
                }

                then("implementation is created") { result in
                    expect(result.implementation).to(equal(
                        ViewImpl("Tested") {
                            ViewImpl("Column") {
                                TextImpl(text: "Text 1")
                                TextImpl(text: "Text 2")

                                TextImpl(text: "Last text")
                            }
                        }
                    ))
                }
            }

            when("the optional is flipped to on") {
                given {
                    Tested(full: false)
                    Tested(full: true)
                }

                then("implementation is created") { result in
                    expect(result.implementation).to(equal(
                        ViewImpl("Tested") {
                            ViewImpl("Column") {
                                TextImpl(text: "Text 1")
                                TextImpl(text: "Text 2")

                                TextImpl(text: "Text 3")
                                TextImpl(text: "Text 4")

                                TextImpl(text: "Last text")
                            }
                        }
                    ))
                }
            }
        }
    }
}
