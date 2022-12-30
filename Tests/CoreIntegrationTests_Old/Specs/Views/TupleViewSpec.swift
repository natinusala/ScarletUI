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

class TupleViewSpecSpec: ScarletCoreSpec {
    static let describing = "a view with multiple children"

    struct Tested: TestView {
        var body: some View {
            Row {
                Rectangle(color: .black)

                Column {
                    Rectangle(color: .red)
                    Rectangle(color: .green)
                    Rectangle(color: .blue)
                }

                Column {
                    Rectangle(color: .orange)
                    Rectangle(color: .yellow)
                }

                Rectangle(color: .black)
            }
        }

        static func spec() -> Specs {
            when("the view is created") {
                given {
                    Tested()
                }

                then("implementation is created") { result in
                    expect(result.implementation).to(equal(
                        ViewImpl("Tested") {
                            ViewImpl("Row") {
                                ViewImpl("Rectangle") {
                                    ViewImpl("EmptyView", fill: .black, grow: 1.0)
                                }

                                ViewImpl("Column") {
                                    ViewImpl("Rectangle") {
                                        ViewImpl("EmptyView", fill: .red, grow: 1.0)
                                    }
                                    ViewImpl("Rectangle") {
                                        ViewImpl("EmptyView", fill: .green, grow: 1.0)
                                    }
                                    ViewImpl("Rectangle") {
                                        ViewImpl("EmptyView", fill: .blue, grow: 1.0)
                                    }
                                }

                                ViewImpl("Column") {
                                    ViewImpl("Rectangle") {
                                        ViewImpl("EmptyView", fill: .orange, grow: 1.0)
                                    }
                                    ViewImpl("Rectangle") {
                                        ViewImpl("EmptyView", fill: .yellow, grow: 1.0)
                                    }
                                }

                                ViewImpl("Rectangle") {
                                    ViewImpl("EmptyView", fill: .black, grow: 1.0)
                                }
                            }
                        }
                    ))
                }
            }
        }
    }
}
