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

@testable import ScarletCore

let tryEquatableSpecs: [(_: String, lhs: Any, rhs: Any, expected: Bool?)] = [
    // Structs
    ("nonconforming structs", lhs: NonEquatableStruct(val1: true, val2: 6845), rhs: NonEquatableStruct(val1: true, val2: 6845), expected: nil),
    ("conforming structs", lhs: EquatableStruct(val1: true, val2: 785), rhs: EquatableStruct(val1: true, val2: 785), expected: true),
    ("conforming structs", lhs: EquatableStruct(val1: true, val2: 785), rhs: EquatableStruct(val1: false, val2: 654981), expected: false),
    // Standard types
    ("strings", lhs: "test string 1", rhs: "test string 1", expected: true),
    ("strings", lhs: "test string 1", rhs: "test string 2", expected: false),
    ("integers", lhs: 1234, rhs: 1234, expected: true),
    ("integers", lhs: 1234, rhs: 4321, expected: false),
    ("floats", lhs: 1234.5, rhs: 1234.5, expected: true),
    ("floats", lhs: 1234.5, rhs: 4321.5, expected: false),
    // Classes
    ("nonconforming classes", lhs: NonEquatableClass(val1: true, val2: 47), rhs: NonEquatableClass(val1: true, val2: 47), expected: nil),
    ("conforming classes", lhs: EquatableClass(val1: true, val2: 74), rhs: EquatableClass(val1: true, val2: 74), expected: true),
    ("conforming classes", lhs: EquatableClass(val1: true, val2: 684), rhs: EquatableClass(val1: true, val2: 74), expected: false),
    // Tuples (will conform to Equatable once SE-0283 is implemented)
    ("conforming tuples", lhs: ("string 1", 0, 1), rhs: ("string 1", 0, 1), expected: nil),
    ("conforming tuples", lhs: ("string 1", 100, 8), rhs: ("string 1", 0, 1), expected: nil),
    ("nonconforming tuples", lhs: ("string 1", 100, NonEquatableClass(val1: true, val2: 789)), rhs: ("string 1", 0, NonEquatableClass(val1: false, val2: 11)), expected: nil),
    // Enums
    ("conforming enums", lhs: EquatableEnum.int(1234), rhs: EquatableEnum.int(1234), expected: true),
    ("conforming enums", lhs: EquatableEnum.int(4321), rhs: EquatableEnum.int(8888), expected: false),
    ("nonconforming enums", lhs: NonEquatableEnum.int(1234), rhs: NonEquatableEnum.int(1234), expected: nil),
    // Closures (will most likely never conform)
    ("nonconforming closures", lhs: {(param: Int) in return param + 10}, rhs: {(param: Int) in return param + 10}, expected: nil),
    // Arrays
    ("conforming arrays", lhs: [1, 2, 3, 4], rhs: [1, 2, 3, 4], expected: true),
    ("conforming arrays", lhs: [1, 2, 3, 4], rhs: [8, 7, 8, 4], expected: false),
    ("nonconforming arrays", lhs: [NonEquatableEnum.int(1234), NonEquatableEnum.int(4321)], rhs: [NonEquatableEnum.int(1234), NonEquatableEnum.int(4321)], expected: nil),
    // Dicts values (keys are always conforming since `Hashable` conforms to `Equatable`)
    ("conforming dicts", lhs: [1: 2, 3: 4], rhs: [1: 2, 3: 4], expected: true),
    ("conforming dicts", lhs: [1: 2, 3: 4], rhs: [8: 7, 4: 4], expected: false),
    ("nonconforming dicts", lhs: [10: NonEquatableEnum.int(4321)], rhs: [10: NonEquatableEnum.int(4321)], expected: nil),
    // Optionals - cast to `Any` is to silence an implicit coercion warning
    ("conforming optionals", lhs: Int?.some(10) as Any, rhs: Int?.some(10) as Any, expected: true),
    ("conforming optionals", lhs: Int?.some(10) as Any, rhs: Int?.some(250) as Any, expected: false),
    ("nonconforming optionals", lhs: NonEquatableEnum?.some(NonEquatableEnum.int(10)) as Any, rhs: NonEquatableEnum?.some(NonEquatableEnum.int(10)) as Any, expected: nil),
    ("nil optionals", lhs: Int?.none as Any, rhs: Int?.none as Any, expected: true),
]

class TryEquatableSpec: QuickSpec {
    override func spec() {
        describe("`tryEquatable`") {
            for (description, lhs, rhs, expected) in tryEquatableSpecs {
                context("comparing \(description)") {
                    let ctx: (String, String)
                    if let expected = expected {
                        ctx = expected ? ("when equal", "returns true") : ("when different", "returns false")
                    } else {
                        ctx = ("when nonconforming", "returns nil")
                    }

                    context(ctx.0) {
                        it(ctx.1) {
                            if expected == nil {
                                expect(tryEquatable(lhs: lhs, rhs: rhs)).to(beNil())
                            } else {
                                expect(tryEquatable(lhs: lhs, rhs: rhs)).to(equal(expected))
                            }
                        }
                    }
                }
            }
        }
    }
}

fileprivate struct NonEquatableStruct {
    var val1: Bool
    var val2: Int
}

fileprivate struct EquatableStruct: Equatable {
    var val1: Bool
    var val2: Int
}

fileprivate enum NonEquatableEnum {
    case bool(Bool)
    case int(Int)
}

fileprivate enum EquatableEnum: Equatable {
    case bool(Bool)
    case int(Int)
}

fileprivate class NonEquatableClass {
    var val1: Bool
    var val2: Int

    init(val1: Bool, val2: Int) {
        self.val1 = val1
        self.val2 = val2
    }
}

fileprivate class EquatableClass: Equatable {
    var val1: Bool
    var val2: Int

    init(val1: Bool, val2: Int) {
        self.val1 = val1
        self.val2 = val2
    }

    static func == (lhs: EquatableClass, rhs: EquatableClass) -> Bool {
        return lhs.val1 == rhs.val1 && lhs.val2 == rhs.val2
    }
}
