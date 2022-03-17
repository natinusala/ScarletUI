
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

import Quick
import Nimble

@testable import ScarletUICore

class TryEquatableSpecs: QuickSpec {
    override func spec() {
        describe("`tryEquatable`") {
            context("when type is not conforming") {
                it("returns `nil`") {
                    let val: Any = NonEquatableConformingStruct(val1: true, val2: 6845)

                    let result = tryEquatable(lhs: val, rhs: val)

                    expect(result).to(beNil())
                }
            }

            context("when type is conforming") {
                it("returns `true` when values are equal") {
                    let lhs: Any = EquatableConformingStruct(val1: true, val2: 785)
                    let rhs: Any = EquatableConformingStruct(val1: true, val2: 785)

                    let result = tryEquatable(lhs: lhs, rhs: rhs)

                    expect(result).to(beTrue())
                }

                it("returns `false` when values are different") {
                    let lhs: Any = EquatableConformingStruct(val1: true, val2: 785)
                    let rhs: Any = EquatableConformingStruct(val1: false, val2: 654981)

                    let result = tryEquatable(lhs: lhs, rhs: rhs)

                    expect(result).to(beFalse())
                }
            }
        }
    }
}

struct NonEquatableConformingStruct {
    var val1: Bool
    var val2: Int
}

struct EquatableConformingStruct: Equatable {
    var val1: Bool
    var val2: Int
}
