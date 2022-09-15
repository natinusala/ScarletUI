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

class OptionalViewToggleMultipleSpec: ScarletSpec {
    static let describing = "a view with an optional view containing multiple views"

    struct Tested: TestView {
        let flip: Bool

        var body: some View {
            Text("Beginning")

            if flip {
                Text("Flipped 1")
                Text("Flipped 2")
                Text("Flipped 3")
            }

            Text("Ending")
        }

        static func spec() -> Spec {
            when("the view is created with the optional on") {
                given {
                    Tested(flip: true)
                }

                then("implementation is created") { result in
                    expect(result.implementation).to(equal(
                        ViewImpl("Tested") {
                            TextImpl(text: "Beginning")

                            TextImpl(text: "Flipped 1")
                            TextImpl(text: "Flipped 2")
                            TextImpl(text: "Flipped 3")

                            TextImpl(text: "Ending")
                        }
                    ))
                }
            }

            when("the view is created with the optional off") {
                given {
                    Tested(flip: false)
                }

                then("implementation is created") { result in
                    expect(result.implementation).to(equal(
                        ViewImpl("Tested") {
                            TextImpl(text: "Beginning")
                            TextImpl(text: "Ending")
                        }
                    ))
                }
            }

            when("the optional is flipped to off") {
                given {
                    Tested(flip: true)
                    Tested(flip: false)
                }

                then("implementation is updated") { result in
                    expect(result.implementation).to(equal(
                        ViewImpl("Tested") {
                            TextImpl(text: "Beginning")
                            TextImpl(text: "Ending")
                        }
                    ))
                }
            }

            when("the optional is flipped to on") {
                given {
                    Tested(flip: false)
                    Tested(flip: true)
                }

                then("implementation is updated") { result in
                    expect(result.implementation).to(equal(
                        ViewImpl("Tested") {
                            TextImpl(text: "Beginning")

                            TextImpl(text: "Flipped 1")
                            TextImpl(text: "Flipped 2")
                            TextImpl(text: "Flipped 3")

                            TextImpl(text: "Ending")
                        }
                    ))
                }
            }
        }
    }
}
