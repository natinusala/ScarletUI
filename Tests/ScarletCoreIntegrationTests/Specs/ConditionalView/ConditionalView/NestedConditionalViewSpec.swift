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

class NestedConditionalViewSpec: ScarletSpec {
    static var describing = "a view with nested conditionals"

    struct Tested: TestView {
        let value: Int

        var body: some View {
            Row {
                if value > 20 {
                    Text("Value is > 20")

                    if value > 30 {
                        Text("Value is > 30")
                    } else if value > 25 {
                        Text("Value is > 25")
                    }
                } else if value > 10 {
                    Text("Value is > 10")

                    if value > 15 {
                        Text("Value is > 15")
                    }
                } else {
                    Text("Value is unknown")
                }
            }
        }

        static func spec() -> Spec {
            when("the view is created") {
                given {
                    Tested(value: 16)
                }

                then("implementation is created") { result in
                    expect(result.implementation).to(equal(
                        ViewImpl("Tested") {
                            ViewImpl("Row") {
                                TextImpl(text: "Value is > 10")
                                TextImpl(text: "Value is > 15")
                            }
                        }
                    ))
                }
            }

            when("the view is updated") {
                given {
                    Tested(value: 16)
                    Tested(value: 35)
                }

                then("implementation is updated") { result in
                    expect(result.implementation).to(equal(
                        ViewImpl("Tested") {
                            ViewImpl("Row") {
                                TextImpl(text: "Value is > 20")
                                TextImpl(text: "Value is > 30")
                            }
                        }
                    ))
                }
            }
        }
    }
}
