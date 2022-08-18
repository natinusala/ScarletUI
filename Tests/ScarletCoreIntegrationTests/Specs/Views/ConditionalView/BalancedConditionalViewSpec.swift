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

class BalancedConditionalViewSpecDefinition: SpecDefinition {
    static let describing = "a view with balanced conditionals"

    struct Tested: TestView {
        let first: Bool

        var body: some View {
            if first {
                Rectangle(color: .white)
                Rectangle(color: .black)
            } else {
                Rectangle(color: .yellow)
                Rectangle(color: .blue)
            }
        }

        static func spec() -> Specs {
            when("the view is created") {
                given {
                    Tested(first: true)
                }

                then("implementation is created") { result in
                    expect(result.implementation).to(equal(
                        ViewImpl("Tested") {
                            ViewImpl("Rectangle") { ViewImpl("EmptyView", fill: .white, grow: 1.0) }
                            ViewImpl("Rectangle") { ViewImpl("EmptyView", fill: .black, grow: 1.0) }
                        }
                    ))
                }
            }

            when("switching from first to second") {
                given {
                    Tested(first: true)
                    Tested(first: false)
                }

                then("implementation is updated") { result in
                    expect(result.implementation).to(equal(
                        ViewImpl("Tested") {
                            ViewImpl("Rectangle") { ViewImpl("EmptyView", fill: .yellow, grow: 1.0) }
                            ViewImpl("Rectangle") { ViewImpl("EmptyView", fill: .blue, grow: 1.0) }
                        }
                    ))
                }
            }
        }
    }
}

typealias BalancedConditionalViewSpec = ScarletSpec<BalancedConditionalViewSpecDefinition>
