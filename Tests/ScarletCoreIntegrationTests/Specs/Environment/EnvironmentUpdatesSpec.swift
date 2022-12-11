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

/// Tests that environment changes only updates the right elements.
class EnvironmentUpdatesSpec: ScarletSpec {
    static let describing = "a tree of views with multiple environment values"

    struct Uses1: View {
        @Environment(\.first)
        var first

        var body: some View {
            Text("First: \(first)")
        }
    }

    struct Uses2: View {
        @Environment(\.second)
        var second

        var body: some View {
            Text("Second: \(second)")
        }
    }

    struct UsesAllFirst: View {
        @Environment(\.first)
        var first

        var body: some View {
            Text("First: \(first)")

            UsesAllSecond()
        }
    }

    struct UsesAllSecond: View {
        @Environment(\.second)
        var second

        var body: some View {
            Text("Second: \(second)")
        }
    }

    struct UsesAll: View {
        var body: some View {
            Text("Should be skipped since it never changes")

            UsesAllFirst()
        }
    }

    struct UsesNone: View {
        var body: some View {
            Text("Uses no changed environment values, never updated")
        }
    }

    struct Tested: TestView {
        let first: Int
        let second: String

        var body: some View {
            Row {
                UsesNone()
                Uses1()
                Uses2()
                UsesAll()
            }
            .environment(\.first, value: first)
            .environment(\.second, value: second)
        }

        static func spec() -> Spec {
            when("the tree is created") {
                given {
                    Tested(first: 10, second: "world")
                }

                then("implementation is created") { result in
                    expect(result.implementation).to(equal(
                        ViewImpl("Tested") {
                            ViewImpl("Row") {
                                ViewImpl("UsesNone") {
                                    TextImpl(text: "Uses no changed environment values, never updated")
                                }

                                ViewImpl("Uses1") {
                                    TextImpl(text: "First: 10")
                                }

                                ViewImpl("Uses2") {
                                    TextImpl(text: "Second: world")
                                }

                                ViewImpl("UsesAll") {
                                    TextImpl(text: "Should be skipped since it never changes")

                                    ViewImpl("UsesAllFirst") {
                                        TextImpl(text: "First: 10")

                                        ViewImpl("UsesAllSecond") {
                                            TextImpl(text: "Second: world")
                                        }
                                    }
                                }
                            }
                        }
                    ))
                }
            }

            when("no environment values change") {
                given {
                    Tested(first: 10, second: "world")
                    Tested(first: 10, second: "world")
                }

                then("tested body is called") { result in
                    expect(result.bodyCalled(of: Tested.self)).to(beTrue())
                }

                then("sub views body is not called") { result in
                    expect(result.bodyCalled(of: UsesNone.self)).to(beFalse())
                    expect(result.bodyCalled(of: UsesAll.self)).to(beFalse())
                    expect(result.bodyCalled(of: UsesAllFirst.self)).to(beFalse())
                    expect(result.bodyCalled(of: UsesAllSecond.self)).to(beFalse())
                    expect(result.bodyCalled(of: Uses1.self)).to(beFalse())
                    expect(result.bodyCalled(of: Uses2.self)).to(beFalse())
                }

                then("implementation is untouched") { result in
                    expect(result.implementation).to(equal(
                        ViewImpl("Tested") {
                            ViewImpl("Row") {
                                ViewImpl("UsesNone") {
                                    TextImpl(text: "Uses no changed environment values, never updated")
                                }

                                ViewImpl("Uses1") {
                                    TextImpl(text: "First: 10")
                                }

                                ViewImpl("Uses2") {
                                    TextImpl(text: "Second: world")
                                }

                                ViewImpl("UsesAll") {
                                    TextImpl(text: "Should be skipped since it never changes")

                                    ViewImpl("UsesAllFirst") {
                                        TextImpl(text: "First: 10")

                                        ViewImpl("UsesAllSecond") {
                                            TextImpl(text: "Second: world")
                                        }
                                    }
                                }
                            }
                        }
                    ))
                }
            }

            when("first environment values changes") {
                given {
                    Tested(first: 10, second: "world")
                    Tested(first: 20, second: "world")
                }

                then("tested body is called") { result in
                    expect(result.bodyCalled(of: Tested.self)).to(beTrue())
                }

                then("sub views body is called when needed") { result in
                    expect(result.bodyCalled(of: UsesNone.self)).to(beFalse())
                    expect(result.bodyCalled(of: UsesAll.self)).to(beFalse())
                    expect(result.bodyCalled(of: UsesAllFirst.self)).to(beTrue())
                    expect(result.bodyCalled(of: UsesAllSecond.self)).to(beFalse())
                    expect(result.bodyCalled(of: Uses1.self)).to(beTrue())
                    expect(result.bodyCalled(of: Uses2.self)).to(beFalse())
                }

                then("implementation is untouched") { result in
                    expect(result.implementation).to(equal(
                        ViewImpl("Tested") {
                            ViewImpl("Row") {
                                ViewImpl("UsesNone") {
                                    TextImpl(text: "Uses no changed environment values, never updated")
                                }

                                ViewImpl("Uses1") {
                                    TextImpl(text: "First: 20")
                                }

                                ViewImpl("Uses2") {
                                    TextImpl(text: "Second: world")
                                }

                                ViewImpl("UsesAll") {
                                    TextImpl(text: "Should be skipped since it never changes")

                                    ViewImpl("UsesAllFirst") {
                                        TextImpl(text: "First: 20")

                                        ViewImpl("UsesAllSecond") {
                                            TextImpl(text: "Second: world")
                                        }
                                    }
                                }
                            }
                        }
                    ))
                }
            }

            when("second environment values changes") {
                given {
                    Tested(first: 10, second: "world")
                    Tested(first: 10, second: "foobarbaz")
                }

                then("tested body is called") { result in
                    expect(result.bodyCalled(of: Tested.self)).to(beTrue())
                }

                then("sub views body is called when needed") { result in
                    expect(result.bodyCalled(of: UsesNone.self)).to(beFalse())
                    expect(result.bodyCalled(of: UsesAll.self)).to(beFalse())
                    expect(result.bodyCalled(of: UsesAllFirst.self)).to(beFalse())
                    expect(result.bodyCalled(of: UsesAllSecond.self)).to(beTrue())
                    expect(result.bodyCalled(of: Uses1.self)).to(beFalse())
                    expect(result.bodyCalled(of: Uses2.self)).to(beTrue())
                }

                then("implementation is untouched") { result in
                    expect(result.implementation).to(equal(
                        ViewImpl("Tested") {
                            ViewImpl("Row") {
                                ViewImpl("UsesNone") {
                                    TextImpl(text: "Uses no changed environment values, never updated")
                                }

                                ViewImpl("Uses1") {
                                    TextImpl(text: "First: 10")
                                }

                                ViewImpl("Uses2") {
                                    TextImpl(text: "Second: foobarbaz")
                                }

                                ViewImpl("UsesAll") {
                                    TextImpl(text: "Should be skipped since it never changes")

                                    ViewImpl("UsesAllFirst") {
                                        TextImpl(text: "First: 10")

                                        ViewImpl("UsesAllSecond") {
                                            TextImpl(text: "Second: foobarbaz")
                                        }
                                    }
                                }
                            }
                        }
                    ))
                }
            }

            when("both environment values change") {
                given {
                    Tested(first: 10, second: "world")
                    Tested(first: 20, second: "foobarbaz")
                }

                then("tested body is called") { result in
                    expect(result.bodyCalled(of: Tested.self)).to(beTrue())
                }

                then("sub views body is called when needed") { result in
                    expect(result.bodyCalled(of: UsesNone.self)).to(beFalse())
                    expect(result.bodyCalled(of: UsesAll.self)).to(beFalse())
                    expect(result.bodyCalled(of: UsesAllFirst.self)).to(beTrue())
                    expect(result.bodyCalled(of: UsesAllSecond.self)).to(beTrue())
                    expect(result.bodyCalled(of: Uses1.self)).to(beTrue())
                    expect(result.bodyCalled(of: Uses2.self)).to(beTrue())
                }

                then("implementation is untouched") { result in
                    expect(result.implementation).to(equal(
                        ViewImpl("Tested") {
                            ViewImpl("Row") {
                                ViewImpl("UsesNone") {
                                    TextImpl(text: "Uses no changed environment values, never updated")
                                }

                                ViewImpl("Uses1") {
                                    TextImpl(text: "First: 20")
                                }

                                ViewImpl("Uses2") {
                                    TextImpl(text: "Second: foobarbaz")
                                }

                                ViewImpl("UsesAll") {
                                    TextImpl(text: "Should be skipped since it never changes")

                                    ViewImpl("UsesAllFirst") {
                                        TextImpl(text: "First: 20")

                                        ViewImpl("UsesAllSecond") {
                                            TextImpl(text: "Second: foobarbaz")
                                        }
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

private struct FirstValueKey: EnvironmentKey {
    static let defaultValue = 1
}

private extension EnvironmentValues {
    var first: Int{
        get { self[FirstValueKey.self] }
        set { self[FirstValueKey.self] = newValue }
    }
}

private struct SecondValueKey: EnvironmentKey {
    static let defaultValue = "hello"
}

private extension EnvironmentValues {
    var second: String {
        get { self[SecondValueKey.self] }
        set { self[SecondValueKey.self] = newValue }
    }
}
