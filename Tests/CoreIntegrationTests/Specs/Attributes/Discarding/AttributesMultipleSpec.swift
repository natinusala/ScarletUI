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

/// Skipped: having the same attribute twice on a view is currently UB
/// Must be completed with more cases if unskipped (nothing changes, both change)
class AttributesMultipleSpec: ScarletCoreSpec, Skipped {
    static let describing = "a view with the same attribute applied twice"

    struct Tested: TestView {
        let firstValue: String
        let secondValue: String

        var body: some View {
            Rectangle(color: .orange)
                .id(firstValue)
                .id(secondValue)
        }

        static func spec() -> Spec {
            when("the view is created") {
                given {
                    Tested(firstValue: "first", secondValue: "second")
                }

                then("the first attribute is applied over the second") { result in
                    expect(result.implementation).to(equal(
                        ViewImpl("Tested") {
                            ViewImpl("Rectangle", id: "first").anyChildren()
                        }
                    ))
                }
            }

            when("the second value changes") {
                given {
                    Tested(firstValue: "first", secondValue: "second")
                    Tested(firstValue: "first", secondValue: "another-second")
                }

                then("the applied value doesn't change") { result in
                    expect(result.implementation).to(equal(
                        ViewImpl("Tested") {
                            ViewImpl("Rectangle", id: "first").anyChildren()
                        }
                    ))
                }

                then("value is not set on implementation side") { result in
                    expect(result.testedChildren[0].attributeChanged(\.id)).to(beFalse())
                }
            }

            when("the first value changes") {
                given {
                    Tested(firstValue: "first", secondValue: "second")
                    Tested(firstValue: "another-first", secondValue: "second")
                }

                then("the applied value changes") { result in
                    expect(result.implementation).to(equal(
                        ViewImpl("Tested") {
                            ViewImpl("Rectangle", id: "another-first").anyChildren()
                        }
                    ))
                }

                then("value is set on implementation side") { result in
                    expect(result.testedChildren[0].attributeChanged(\.id)).to(beTrue())
                }
            }
        }
    }
}
