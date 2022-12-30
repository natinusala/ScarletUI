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

class EnvironmentSameValueSpec: ScarletCoreSpec {
    static let describing = "a tree with the multiple environment value set at different levels"

    struct ThirdView: View {
        @Environment(\.test)
        var test

        var body: some View {
            Text("test=\(test)")
        }
    }

    struct SecondView: View {
        let thirdEnv: Int

        @Environment(\.test)
        var test

        var body: some View {
            Text("test=\(test)")

            ThirdView()
                .environment(\.test, value: thirdEnv)
        }
    }

    struct FirstView: View {
        let secondEnv: Int
        let thirdEnv: Int

        @Environment(\.test)
        var test

        var body: some View {
            Text("test=\(test)")

            SecondView(thirdEnv: thirdEnv)
                .environment(\.test, value: secondEnv)
        }
    }

    struct Tested: TestView {
        let firstEnv: Int
        let secondEnv: Int
        let thirdEnv: Int

        @Environment(\.test)
        var test

        var body: some View {
            Text("test=\(test)")

            FirstView(secondEnv: secondEnv, thirdEnv: thirdEnv)
                .environment(\.test, value: firstEnv)
        }

        static func spec() -> Spec {
            when("the tree is created") {
                given {
                    Tested(firstEnv: 10, secondEnv: 20, thirdEnv: 10)
                }

                then("implementation is created") { result in
                    expect(result.implementation).to(equal(
                        ViewImpl("Tested") {
                            TextImpl(text: "test=1")

                            ViewImpl("FirstView") {
                                TextImpl(text: "test=10")

                                ViewImpl("SecondView") {
                                    TextImpl(text: "test=20")

                                    ViewImpl("ThirdView") {
                                        TextImpl(text: "test=10")
                                    }
                                }
                            }
                        }
                    ))
                }
            }

            when("nothing changes") {
                given {
                    Tested(firstEnv: 10, secondEnv: 20, thirdEnv: 10)
                    Tested(firstEnv: 10, secondEnv: 20, thirdEnv: 10)
                }

                then("tested body is called") { result in
                    expect(result.bodyCalled(of: Tested.self)).to(beTrue())
                }

                then("views body is called accordingly") { result in
                    expect(result.bodyCalled(of: FirstView.self)).to(beFalse())
                    expect(result.bodyCalled(of: SecondView.self)).to(beFalse())
                    expect(result.bodyCalled(of: ThirdView.self)).to(beFalse())
                }

                then("implementation is untouched") { result in
                    expect(result.implementation).to(equal(
                        ViewImpl("Tested") {
                            TextImpl(text: "test=1")

                            ViewImpl("FirstView") {
                                TextImpl(text: "test=10")

                                ViewImpl("SecondView") {
                                    TextImpl(text: "test=20")

                                    ViewImpl("ThirdView") {
                                        TextImpl(text: "test=10")
                                    }
                                }
                            }
                        }
                    ))
                }
            }

            when("first environment value changes") {
                given {
                    Tested(firstEnv: 10, secondEnv: 20, thirdEnv: 10)
                    Tested(firstEnv: 20, secondEnv: 20, thirdEnv: 10)
                }

                then("tested body is called") { result in
                    expect(result.bodyCalled(of: Tested.self)).to(beTrue())
                }

                then("views body is called accordingly") { result in
                    expect(result.bodyCalled(of: FirstView.self)).to(beTrue())
                    expect(result.bodyCalled(of: SecondView.self)).to(beFalse())
                    expect(result.bodyCalled(of: ThirdView.self)).to(beFalse())
                }

                then("implementation is updated") { result in
                    expect(result.implementation).to(equal(
                        ViewImpl("Tested") {
                            TextImpl(text: "test=1")

                            ViewImpl("FirstView") {
                                TextImpl(text: "test=20")

                                ViewImpl("SecondView") {
                                    TextImpl(text: "test=20")

                                    ViewImpl("ThirdView") {
                                        TextImpl(text: "test=10")
                                    }
                                }
                            }
                        }
                    ))
                }
            }

            when("second environment value changes to same value as third") {
                given {
                    Tested(firstEnv: 20, secondEnv: 20, thirdEnv: 10)
                    Tested(firstEnv: 20, secondEnv: 10, thirdEnv: 10)
                }

                then("tested body is called") { result in
                    expect(result.bodyCalled(of: Tested.self)).to(beTrue())
                }

                then("views body is called accordingly") { result in
                    expect(result.bodyCalled(of: FirstView.self)).to(beTrue()) // called because `firstEnv` changes
                    expect(result.bodyCalled(of: SecondView.self)).to(beTrue())
                    expect(result.bodyCalled(of: ThirdView.self)).to(beFalse())
                }

                then("implementation is updated") { result in
                    expect(result.implementation).to(equal(
                        ViewImpl("Tested") {
                            TextImpl(text: "test=1")

                            ViewImpl("FirstView") {
                                TextImpl(text: "test=20")

                                ViewImpl("SecondView") {
                                    TextImpl(text: "test=10")

                                    ViewImpl("ThirdView") {
                                        TextImpl(text: "test=10")
                                    }
                                }
                            }
                        }
                    ))
                }
            }

            when("second environment value changes to different value than third") {
                given {
                    Tested(firstEnv: 20, secondEnv: 20, thirdEnv: 10)
                    Tested(firstEnv: 20, secondEnv: 30, thirdEnv: 10)
                }

                then("tested body is called") { result in
                    expect(result.bodyCalled(of: Tested.self)).to(beTrue())
                }

                then("views body is called accordingly") { result in
                    expect(result.bodyCalled(of: FirstView.self)).to(beTrue()) // called because `firstEnv` changes
                    expect(result.bodyCalled(of: SecondView.self)).to(beTrue())
                    expect(result.bodyCalled(of: ThirdView.self)).to(beFalse())
                }

                then("implementation is updated") { result in
                    expect(result.implementation).to(equal(
                        ViewImpl("Tested") {
                            TextImpl(text: "test=1")

                            ViewImpl("FirstView") {
                                TextImpl(text: "test=20")

                                ViewImpl("SecondView") {
                                    TextImpl(text: "test=30")

                                    ViewImpl("ThirdView") {
                                        TextImpl(text: "test=10")
                                    }
                                }
                            }
                        }
                    ))
                }
            }
        }
    }
}

private struct TestEnvironmentKey: EnvironmentKey {
    static let defaultValue = 1
}

private extension EnvironmentValues {
    var test: Int{
        get { self[TestEnvironmentKey.self] }
        set { self[TestEnvironmentKey.self] = newValue }
    }
}
