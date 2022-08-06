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

class TopLevelNestedConditionalViewSpecDefinition: SpecDefinition {
    static var describing = "a view with top level nested conditionals"

    struct Tested: TestView {
        var flip1: Bool
        var flip2: Bool
        var flip3: Bool

        var body: some View {
            if flip1 {
                Text("Enabled")
            } else if flip2 {
                Text("Disabled")
            } else if flip3 {
                Text("Maybe?")
            } else {
                Image(source: "error-icon")
            }
        }

        static func spec() -> Specs {
            when("view is created") {
                given {
                    Tested(flip1: false, flip2: true, flip3: false)
                }

                then("implementation is created") { result in
                    expect(result.implementation).to(equal(
                        ViewImpl("Tested") {
                            TextImpl(text: "Disabled")
                        }
                    ))
                }
            }

            when("view is updated") {
                given {
                    Tested(flip1: false, flip2: true, flip3: false)
                    Tested(flip1: false, flip2: false, flip3: false)
                }

                then("implementation is created") { result in
                    expect(result.implementation).to(equal(
                        ViewImpl("Tested") {
                            ImageImpl(source: "error-icon")
                        }
                    ))
                }
            }
        }
    }
}

typealias TopLevelNestedConditionalViewSpec = ScarletSpec<TopLevelNestedConditionalViewSpecDefinition>
