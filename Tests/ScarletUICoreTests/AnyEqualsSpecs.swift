
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

/// Specs for testing `tryEquatable`.
let tryEquatableSpecs: [(description: String, lhs: Any, rhs: Any, expected: Bool?)] = [
    // Structs
    (description: "nonconforming struct", lhs: NonEquatableStruct(val1: true, val2: 6845), rhs: NonEquatableStruct(val1: true, val2: 6845), expected: nil),
    (description: "conforming struct", lhs: EquatableStruct(val1: true, val2: 785), rhs: EquatableStruct(val1: true, val2: 785), expected: true),
    (description: "conforming struct", lhs: EquatableStruct(val1: true, val2: 785), rhs: EquatableStruct(val1: false, val2: 654981), expected: false),
    // Standard types
    (description: "string", lhs: "test string 1", rhs: "test string 1", expected: true),
    (description: "string", lhs: "test string 1", rhs: "test string 2", expected: false),
    (description: "integer", lhs: 1234, rhs: 1234, expected: true),
    (description: "integer", lhs: 1234, rhs: 4321, expected: false),
    (description: "float", lhs: 1234.5, rhs: 1234.5, expected: true),
    (description: "float", lhs: 1234.5, rhs: 4321.5, expected: false),
    // Classes
    (description: "nonconforming class", lhs: NonEquatableClass(val1: true, val2: 47), rhs: NonEquatableClass(val1: true, val2: 47), expected: nil),
    (description: "conforming class", lhs: EquatableClass(val1: true, val2: 74), rhs: EquatableClass(val1: true, val2: 74), expected: true),
    (description: "conforming class", lhs: EquatableClass(val1: true, val2: 684), rhs: EquatableClass(val1: true, val2: 74), expected: false),
    // Tuples (will conform to Equatable once SE-0283 is implemented)
    (description: "conforming tuple", lhs: ("string 1", 0, 1), rhs: ("string 1", 0, 1), expected: nil),
    (description: "conforming tuple", lhs: ("string 1", 100, 8), rhs: ("string 1", 0, 1), expected: nil),
    (description: "nonconforming tuple", lhs: ("string 1", 100, NonEquatableClass(val1: true, val2: 789)), rhs: ("string 1", 0, NonEquatableClass(val1: false, val2: 11)), expected: nil),
    // Enums
    (description: "conforming enum", lhs: EquatableEnum.int(1234), rhs: EquatableEnum.int(1234), expected: true),
    (description: "conforming enum", lhs: EquatableEnum.int(4321), rhs: EquatableEnum.int(8888), expected: false),
    (description: "nonconforming enum", lhs: NonEquatableEnum.int(1234), rhs: NonEquatableEnum.int(1234), expected: nil),
    // Closures (will most likely never conform)
    (description: "nonconforming closure", lhs: {(param: Int) in return param + 10}, rhs: {(param: Int) in return param + 10}, expected: nil),
    // Arrays
    (description: "conforming array", lhs: [1, 2, 3, 4], rhs: [1, 2, 3, 4], expected: true),
    (description: "conforming array", lhs: [1, 2, 3, 4], rhs: [8, 7, 8, 4], expected: false),
    (description: "nonconforming array", lhs: [NonEquatableEnum.int(1234), NonEquatableEnum.int(4321)], rhs: [NonEquatableEnum.int(1234), NonEquatableEnum.int(4321)], expected: nil),
    // Dicts values (keys are always conforming since `Hashable` conforms to `Equatable`)
    (description: "conforming dict", lhs: [1: 2, 3: 4], rhs: [1: 2, 3: 4], expected: true),
    (description: "conforming dict", lhs: [1: 2, 3: 4], rhs: [8: 7, 4: 4], expected: false),
    (description: "nonconforming dict", lhs: [10: NonEquatableEnum.int(4321)], rhs: [10: NonEquatableEnum.int(4321)], expected: nil),
    // Optionals - cast to `Any` is to silence an implicit coercion warning
    (description: "conforming optional", lhs: Optional<Int>.some(10) as Any, rhs: Optional<Int>.some(10) as Any, expected: true),
    (description: "conforming optional", lhs: Optional<Int>.some(10) as Any, rhs: Optional<Int>.some(250) as Any, expected: false),
    (description: "nonconforming optional", lhs: Optional<NonEquatableEnum>.some(NonEquatableEnum.int(10)) as Any, rhs: Optional<NonEquatableEnum>.some(NonEquatableEnum.int(10)) as Any, expected: nil),
    (description: "nil optional", lhs: Optional<Int>.none as Any, rhs: Optional<Int>.none as Any, expected: true),
]

class TryEquatableSpecs: QuickSpec {
    override func spec() {
        describe("`tryEquatable`") {
            for (description, lhs, rhs, expected) in tryEquatableSpecs {
                context("comparing \(description)") {
                    var ctx: (String, String) {
                        if let expected = expected {
                            return expected ? ("when equal", "returns true") : ("when different", "returns false")
                        }

                        return ("when nonconforming", "returns nil")
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

fileprivate enum EquatableEnum: Equatable {
    case bool(Bool)
    case int(Int)
}

fileprivate enum NonEquatableEnum {
    case bool(Bool)
    case int(Int)
}
