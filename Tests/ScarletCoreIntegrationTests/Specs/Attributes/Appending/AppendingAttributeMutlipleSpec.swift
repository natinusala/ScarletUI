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

class AppendingAttributeMutlipleSpec: ScarletSpec {
    static let describing = "a view with appending attributes"

    struct Tested: TestView {
        let firstTag: String
        let secondTag: String

        var body: some View {
            Text("Some text")
                .tag(firstTag)
                .tag(secondTag)
        }

        static func spec() -> Spec {
            when("the same attribute is applied multiple times") {
                given {
                    Tested(firstTag: "first", secondTag: "second")
                }

                then("all attributes are applied") { result in
                    expect(result.implementation).to(equal(
                        ViewImpl("Tested") {
                            TextImpl(text: "Some text", tags: ["first", "second"])
                        }
                    ))
                }
            }
        }
    }
}
