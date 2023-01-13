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

class ViewSpecSpec: ScarletCoreSpec {
    static let describing = "a view with input"

    struct NestedView: View {
        let value: Bool

        var body: some View {
            EmptyView()
        }
    }

    struct Tested: TestView {
        let variable: Bool
        let anotherVariable: Bool

        var body: some View {
            NestedView(value: variable)
        }

        static func spec() -> Specs {
            when("the view is created") {
                given {
                    Tested(variable: true, anotherVariable: false)
                }

                then("target is created") { result in
                    expect(result.target).to(equal(
                        ViewTarget("Tested") {
                            ViewTarget("NestedView") {
                                ViewTarget("EmptyView")
                            }
                        }
                    ))
                }
            }

            when("the view input does not change") {
                given {
                    Tested(variable: true, anotherVariable: false)
                    Tested(variable: true, anotherVariable: false)
                }

                then("body is not called") { result in
                    expect(result.bodyCalled(of: Tested.self)).to(beFalse())
                }

                then("nested body is not called") { result in
                    expect(result.bodyCalled(of: NestedView.self)).to(beFalse())
                }

                then("target is untouched") { result in
                    expect(result.target).to(equal(
                        ViewTarget("Tested") {
                            ViewTarget("NestedView") {
                                ViewTarget("EmptyView")
                            }
                        }
                    ))
                }
            }

            when("the view input changes") {
                given { 
                    Tested(variable: true, anotherVariable: false)
                    Tested(variable: false, anotherVariable: true)
                }

                then("body is called") { result in
                    expect(result.bodyCalled(of: Tested.self)).to(beTrue())
                }

                then("nested body is called") { result in
                    expect(result.bodyCalled(of: NestedView.self)).to(beTrue())
                }

                then("target is updated") { result in
                    expect(result.target).to(equal(
                        ViewTarget("Tested") {
                            ViewTarget("NestedView") {
                                ViewTarget("EmptyView")
                            }
                        }
                    ))
                }
            }
        }
    }
}
