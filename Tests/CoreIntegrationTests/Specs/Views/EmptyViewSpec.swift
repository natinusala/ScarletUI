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

class EmptyViewSpec: ScarletCoreSpec {
    static let describing = "an empty view"

    struct Tested: TestView {
        var body: some View {
            EmptyView()
        }

        static func spec() -> Spec {
            when("the view is created") {
                given { Tested() }

                then("target is created") { result in
                    expect(result.target).to(equal(
                        ViewTarget("Tested") {
                            ViewTarget("EmptyView")
                        }
                    ))
                }
            }

            when("the view is updated") {
                given {
                    Tested()
                    Tested()
                }

                then("target is untouched") { result in
                    expect(result.target).to(equal(
                        ViewTarget("Tested") {
                            ViewTarget("EmptyView")
                        }
                    ))
                }
            }
        }
    }
}
