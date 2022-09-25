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

class EnvironmentValueSpec: ScarletSpec {
    static let describing = "a view setting environment values"

    struct EnvironmentDisplay: View {
        @Environment(\.test)
        var test

        var body: some View {
            Text("Environment value: \(test)")
        }
    }

    struct Tested: TestView {
        @Environment(\.test)
        var test

        var body: some View {
            Text("Environment value: \(test)")

            EnvironmentDisplay()
                .environment(\.test, value: "hello")
        }

        static func spec() -> Spec {
            when("view is created") {
                given {
                    Tested()
                }

                then("implementation is created") { result in
                    expect(result.implementation).to(equal(
                        ViewImpl("Tested") {
                            TextImpl(text: "Environment value: default value")

                            ViewImpl("EnvironmentDisplay") {
                                TextImpl(text: "Environment value: hello")
                            }
                        }
                    ))
                }
            }
        }
    }
}

struct TestEnvironmentKey: EnvironmentKey {
    static let defaultValue = "default value"
}

extension EnvironmentValues {
    var test: String {
        get { self[TestEnvironmentKey.self] }
        set { self[TestEnvironmentKey.self] = newValue }
    }
}
