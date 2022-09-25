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

class EmptyConditionalViewSpec: ScarletSpec {
    static let describing = "a view with empty conditionals"

    struct Tested: TestView {
        let first: Bool
        let toggle: Bool

        var body: some View {
            Rectangle(color: .blue)

            if first {
                if toggle {} else {
                    Rectangle(color: .white)
                    Rectangle(color: .yellow)
                }
            } else {
                if toggle {
                    Rectangle(color: .orange)
                    Rectangle(color: .yellow)
                } else {}
            }
        }

        static func spec() -> Spec {
            when("creating with empty first") {
                given {
                    Tested(first: true, toggle: true)
                }

                then("implementations are created") { result in
                    expect(result.implementation).to(equal(
                        ViewImpl("Tested") {
                            ViewImpl("Rectangle") { ViewImpl("EmptyView", fill: .blue, grow: 1.0) }
                        }
                    ))

                }
            }

            when("creating with full first") {
                given {
                    Tested(first: true, toggle: false)
                }

                then("implementations are created") { result in
                    expect(result.implementation).to(equal(
                        ViewImpl("Tested") {
                            ViewImpl("Rectangle") { ViewImpl("EmptyView", fill: .blue, grow: 1.0) }

                            ViewImpl("Rectangle") { ViewImpl("EmptyView", fill: .white, grow: 1.0) }
                            ViewImpl("Rectangle") { ViewImpl("EmptyView", fill: .yellow, grow: 1.0) }
                        }
                    ))

                }
            }

            when("creating with empty second") {
                given {
                    Tested(first: false, toggle: false)
                }

                then("implementations are created") { result in
                    expect(result.implementation).to(equal(
                        ViewImpl("Tested") {
                            ViewImpl("Rectangle") { ViewImpl("EmptyView", fill: .blue, grow: 1.0) }
                        }
                    ))

                }
            }

            when("creating with full second") {
                given {
                    Tested(first: false, toggle: true)
                }

                then("implementations are created") { result in
                    expect(result.implementation).to(equal(
                        ViewImpl("Tested") {
                            ViewImpl("Rectangle") { ViewImpl("EmptyView", fill: .blue, grow: 1.0) }

                            ViewImpl("Rectangle") { ViewImpl("EmptyView", fill: .orange, grow: 1.0) }
                            ViewImpl("Rectangle") { ViewImpl("EmptyView", fill: .yellow, grow: 1.0) }
                        }
                    ))

                }
            }

            when("removing first elements") {
                given {
                    Tested(first: true, toggle: false)
                    Tested(first: true, toggle: true)
                }

                then("implementations are updated") { result in
                    expect(result.implementation).to(equal(
                        ViewImpl("Tested") {
                            ViewImpl("Rectangle") { ViewImpl("EmptyView", fill: .blue, grow: 1.0) }
                        }
                    ))
                }
            }

            when("adding first elements") {
                given {
                    Tested(first: true, toggle: true)
                    Tested(first: true, toggle: false)
                }

                then("implementations are updated") { result in
                    expect(result.implementation).to(equal(
                        ViewImpl("Tested") {
                            ViewImpl("Rectangle") { ViewImpl("EmptyView", fill: .blue, grow: 1.0) }

                            ViewImpl("Rectangle") { ViewImpl("EmptyView", fill: .white, grow: 1.0) }
                            ViewImpl("Rectangle") { ViewImpl("EmptyView", fill: .yellow, grow: 1.0) }
                        }
                    ))
                }
            }

            when("removing second elements") {
                given {
                    Tested(first: false, toggle: true)
                    Tested(first: false, toggle: false)
                }

                then("implementations are updated") { result in
                    expect(result.implementation).to(equal(
                        ViewImpl("Tested") {
                            ViewImpl("Rectangle") { ViewImpl("EmptyView", fill: .blue, grow: 1.0) }
                        }
                    ))
                }
            }

            when("adding second elements") {
                given {
                    Tested(first: false, toggle: false)
                    Tested(first: false, toggle: true)
                }

                then("implementations are updated") { result in
                    expect(result.implementation).to(equal(
                        ViewImpl("Tested") {
                            ViewImpl("Rectangle") { ViewImpl("EmptyView", fill: .blue, grow: 1.0) }

                            ViewImpl("Rectangle") { ViewImpl("EmptyView", fill: .orange, grow: 1.0) }
                            ViewImpl("Rectangle") { ViewImpl("EmptyView", fill: .yellow, grow: 1.0) }
                        }
                    ))
                }
            }
        }
    }
}
