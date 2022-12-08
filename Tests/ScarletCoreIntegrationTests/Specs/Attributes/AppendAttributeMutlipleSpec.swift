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

private enum Signal: Int, TestSignal {
    case increment
    case decrement
}

class AppendAttributeMutlipleSpec: ScarletSpec {
    static let describing = "a view"

    struct Tested: TestView {
        @State private var counter = 0

        var body: some View {
            Text("Counter: \(counter)")
                .onTestSignal(Signal.increment) {
                    counter += 1
                }
                .onTestSignal(Signal.decrement) {
                    counter -= 1
                }
        }

        static func spec() -> Spec {
            when("the same attribute is applied multiple times") {
                given {
                    Tested()

                    signal(Signal.increment)
                    signal(Signal.increment)
                    signal(Signal.decrement)
                }

                then("all attributes are applied") { result in
                    expect(result.implementation).to(equal(
                        ViewImpl("Tested") {
                            TextImpl(text: "Counter: 1")
                        }
                    ))
                }
            }
        }
    }
}
