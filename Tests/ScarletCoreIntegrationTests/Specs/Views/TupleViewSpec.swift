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

class TupleViewSpecDefinition: SpecDefinition {
    static let describing = "a view with multiple children"
    static let testing = Tested()

    struct Tested: TestView {
        var body: some View {
            EmptyView().id("id0")
            EmptyView().id("id1")
            EmptyView().id("id2")
        }

        func spec() -> Specs {
            when("the view is created") {
                create()

                then("implementation is created") { result in
                    expect(result.implementation).to(equal(
                        ViewImpl("Tested") {
                            ViewImpl("EmptyView", id: "id0")
                            ViewImpl("EmptyView", id: "id1")
                            ViewImpl("EmptyView", id: "id2")
                        }
                    ))
                }
            }
        }
    }
}

typealias TupleViewSpec = ScarletSpec<TupleViewSpecDefinition>
