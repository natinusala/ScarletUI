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

class ViewSpecsDefinition: SpecDefinition {
    static let describing = "view updates"
    static let testing = Tested(variable: true, anotherVariable: false)

    struct Tested: TestView {
        let variable: Bool
        let anotherVariable: Bool

        @State private var stateVariable = false

        var body: some View {
            EmptyView()
        }

        func spec() -> Specs {
            when(updatingWith: Tested(variable: true, anotherVariable: false), "the view input does not change") {
                then("body is not called") { result in
                    expect(result.bodyCalled(of: Tested.self)).to(beFalse())
                }
            }

            when(updatingWith: Tested(variable: false, anotherVariable: true), "the view input changes") {
                then("body is called") { result in
                    expect(result.bodyCalled(of: Tested.self)).to(beTrue())
                }
            }
        }
    }
}

typealias ViewSpecs = ScarletSpec<ViewSpecsDefinition>
