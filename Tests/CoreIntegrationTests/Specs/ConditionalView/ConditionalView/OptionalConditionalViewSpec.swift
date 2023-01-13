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

class OptionalConditionalViewSpec: ScarletCoreSpec {
    static let describing = "a view with conditionals containing optionals"

    struct Tested: TestView {
        let first: Bool
        let optional: Bool

        var body: some View {
            if first {
                Rectangle(color: .white)

                if optional {
                    Rectangle(color: .red)
                    Rectangle(color: .green)
                    Rectangle(color: .blue)
                }

                Rectangle(color: .black)
            } else {
                Rectangle(color: .orange)
                Rectangle(color: .yellow)
            }
        }

        static func spec() -> Spec {
            when("the view is created without the optional") {
                given {
                    Tested(first: true, optional: false)
                }

                then("target is created") { result in
                    expect(result.target).to(equal(
                        ViewTarget("Tested") {
                            ViewTarget("Rectangle") { ViewTarget("EmptyView", fill: .white, grow: 1.0) }
                            ViewTarget("Rectangle") { ViewTarget("EmptyView", fill: .black, grow: 1.0) }
                        }
                    ))
                }
            }

            when("the view is created with the optional") {
                given {
                    Tested(first: true, optional: true)
                }

                then("target is created") { result in
                    expect(result.target).to(equal(
                        ViewTarget("Tested") {
                            ViewTarget("Rectangle") { ViewTarget("EmptyView", fill: .white, grow: 1.0) }

                            ViewTarget("Rectangle") { ViewTarget("EmptyView", fill: .red, grow: 1.0) }
                            ViewTarget("Rectangle") { ViewTarget("EmptyView", fill: .green, grow: 1.0) }
                            ViewTarget("Rectangle") { ViewTarget("EmptyView", fill: .blue, grow: 1.0) }

                            ViewTarget("Rectangle") { ViewTarget("EmptyView", fill: .black, grow: 1.0) }
                        }
                    ))
                }
            }

            when("switching from first to second without optional") {
                given {
                    Tested(first: true, optional: false)
                    Tested(first: false, optional: false)
                }

                then("target is updated") { result in
                    expect(result.target).to(equal(
                        ViewTarget("Tested") {
                            ViewTarget("Rectangle") { ViewTarget("EmptyView", fill: .orange, grow: 1.0) }
                            ViewTarget("Rectangle") { ViewTarget("EmptyView", fill: .yellow, grow: 1.0) }
                        }
                    ))
                }
            }

            when("switching from first to second with optional") {
                given {
                    Tested(first: true, optional: true)
                    Tested(first: false, optional: true)
                }

                then("target is updated") { result in
                    expect(result.target).to(equal(
                        ViewTarget("Tested") {
                            ViewTarget("Rectangle") { ViewTarget("EmptyView", fill: .orange, grow: 1.0) }
                            ViewTarget("Rectangle") { ViewTarget("EmptyView", fill: .yellow, grow: 1.0) }
                        }
                    ))
                }
            }

            when("inserting optional") {
                given {
                    Tested(first: true, optional: false)
                    Tested(first: true, optional: true)
                }

                then("target is updated") { result in
                    expect(result.target).to(equal(
                        ViewTarget("Tested") {
                            ViewTarget("Rectangle") { ViewTarget("EmptyView", fill: .white, grow: 1.0) }

                            ViewTarget("Rectangle") { ViewTarget("EmptyView", fill: .red, grow: 1.0) }
                            ViewTarget("Rectangle") { ViewTarget("EmptyView", fill: .green, grow: 1.0) }
                            ViewTarget("Rectangle") { ViewTarget("EmptyView", fill: .blue, grow: 1.0) }

                            ViewTarget("Rectangle") { ViewTarget("EmptyView", fill: .black, grow: 1.0) }
                        }
                    ))
                }
            }

            when("removing optional") {
                given {
                    Tested(first: true, optional: true)
                    Tested(first: true, optional: false)
                }

                then("target is updated") { result in
                    expect(result.target).to(equal(
                        ViewTarget("Tested") {
                            ViewTarget("Rectangle") { ViewTarget("EmptyView", fill: .white, grow: 1.0) }
                            ViewTarget("Rectangle") { ViewTarget("EmptyView", fill: .black, grow: 1.0) }
                        }
                    ))
                }
            }
        }
    }
}
