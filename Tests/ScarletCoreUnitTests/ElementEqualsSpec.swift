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
import Runtime

@testable import ScarletCore

fileprivate let nonEquatableObjectEqual1 = NonEquatableClass(val1: true, val2: 250)
fileprivate let nonEquatableObjectEqual2 = NonEquatableClass(val1: true, val2: 250)
fileprivate let nonEquatableObject3 = NonEquatableClass(val1: false, val2: 2500)

fileprivate let equatableObjectEqual1 = EquatableClass(val1: true, val2: 250)
fileprivate let equatableObjectEqual2 = EquatableClass(val1: true, val2: 250)
fileprivate let equatableObject3 = EquatableClass(val1: false, val2: 2500)

fileprivate let classWrappedObject1 = ClassWrappedNonEquatableStruct(val1: false, val2: 780)
fileprivate let classWrappedObject2 = classWrappedObject1

/// Specs for testing `elementEquals`.
let elementEqualsSpecs: [(_: String, lhs: Any, rhs: Any, expected: Bool)] = [
    // Different types
    ("different equatable types", lhs: 10, rhs: "test string", expected: false),
    ("different nonequatable types", lhs: NonEquatableEnum.int(10), rhs: { (val: Bool) in !val }, expected: false),
    // Equatables
    ("equatable strings", lhs: "test string 1", rhs: "test string 1", expected: true),
    ("equatable strings", lhs: "test string 1", rhs: "test string 2", expected: false),
    ("equatable integers", lhs: 1234, rhs: 1234, expected: true),
    ("equatable integers", lhs: 1234, rhs: 4321, expected: false),
    ("equatable floats", lhs: 1234.5, rhs: 1234.5, expected: true),
    ("equatable floats", lhs: 1234.5, rhs: 4321.5, expected: false),
    ("equatable structs", lhs: EquatableStruct(val1: true, val2: 10), rhs: EquatableStruct(val1: true, val2: 10), expected: true),
    ("equatable structs", lhs: EquatableStruct(val1: true, val2: 20), rhs: EquatableStruct(val1: true, val2: 750), expected: false),
    ("equatable enums", lhs: EquatableEnum.int(1234), rhs: EquatableEnum.int(1234), expected: true),
    ("equatable enums", lhs: EquatableEnum.int(4321), rhs: EquatableEnum.int(8888), expected: false),
    ("nonequatable same enums", lhs: NonEquatableEnum.int(1234), rhs: NonEquatableEnum.int(1234), expected: true),
    ("nonequatable same enums", lhs: NonEquatableEnum.int(1234), rhs: NonEquatableEnum.int(8888), expected: false),
    ("nonequatable different enums", lhs: NonEquatableEnum.int(1234), rhs: NonEquatableEnum.bool(false), expected: false),
    ("unbalanced enums", lhs: UnbalancedEnum.none, rhs: UnbalancedEnum.one("string"), expected: false),
    ("equatable dicts", lhs: [1: 2, 3: 4], rhs: [1: 2, 3: 4], expected: true),
    ("equatable dicts", lhs: [1: 2, 3: 4], rhs: [8: 7, 4: 4], expected: false),
    // Tuples
    ("nonequatable tuples", lhs: ("string 1", 100, NonEquatableStruct(val1: true, val2: 789)), rhs: ("string 1", 100, NonEquatableStruct(val1: true, val2: 789)), expected: true),
    ("nonequatable tuples", lhs: ("string 1", 100, NonEquatableStruct(val1: true, val2: 7)), rhs: ("string 1", 0, NonEquatableStruct(val1: false, val2: 250)), expected: false),
    // Objects
    ("different nonequatable objects with same value", lhs: nonEquatableObjectEqual1, rhs: nonEquatableObjectEqual2, expected: false),
    ("different nonequatable objects with different values", lhs: nonEquatableObjectEqual1, rhs: nonEquatableObject3, expected: false),
    ("same nonequatable objects", lhs: nonEquatableObject3, rhs: nonEquatableObject3, expected: true),
    ("different equatable objects with same value", lhs: equatableObjectEqual1, rhs: equatableObjectEqual2, expected: true),
    ("different equatable objects with different values", lhs: equatableObjectEqual1, rhs: equatableObject3, expected: false),
    ("same equatable objects", lhs: equatableObject3, rhs: equatableObject3, expected: true),
    // Field by field comparison
    ("nonequatable structs", lhs: NonEquatableStruct(val1: true, val2: 6845), rhs: NonEquatableStruct(val1: true, val2: 6845), expected: true),
    ("nonequatable structs with stored property wrappers", lhs: StoredWrappedNonEquatableStruct(val1: true, val2: 6845), rhs: StoredWrappedNonEquatableStruct(val1: true, val2: 6845), expected: true),
    ("nonequatable structs with computed property wrappers", lhs: ComputedWrappedNonEquatableStruct(val1: true, val2: 6845), rhs: ComputedWrappedNonEquatableStruct(val1: true, val2: 6845), expected: true),
    ("nonequatable structs with class property wrappers", lhs: ClassWrappedNonEquatableStruct(val1: true, val2: 50), rhs: ClassWrappedNonEquatableStruct(val1: true, val2: 50), expected: false), // this is never equal because field by field comparison will use `===` on `ClassWrapped`, which are different
    ("nonequatable structs with class property wrappers", lhs: classWrappedObject1, rhs: classWrappedObject2, expected: true), // this is equal because the `ClassWrapped` references inside the structs are the same
    // Arrays
    ("nonequatable arrays", lhs: [NonEquatableEnum.int(1234), NonEquatableEnum.int(4321)], rhs: [NonEquatableEnum.int(1234), NonEquatableEnum.int(4321)], expected: true),
    ("nonequatable arrays", lhs: [NonEquatableEnum.int(1234), NonEquatableEnum.int(8888)], rhs: [NonEquatableEnum.int(1234), NonEquatableEnum.int(4321)], expected: false),
    // Dicts
    ("nonequatable dicts", lhs: [10: NonEquatableEnum.int(4321)], rhs: [10: NonEquatableEnum.int(4321)], expected: true),
    ("nonequatable dicts", lhs: [10: NonEquatableEnum.int(4321)], rhs: [10: NonEquatableEnum.int(8874)], expected: false),
    // Closures (will most likely never conform)
    ("closures", lhs: {(param: Int) in return param + 10}, rhs: {(param: Int) in return param + 20}, expected: false),
    // Dynamic properties ignore
    ("changing structs with still dynamic properties", lhs: HasDynamicProperties(dynamicProperty: 10, value: true), rhs: HasDynamicProperties(dynamicProperty: 10, value: false), expected: false),
    ("still structs with still dynamic properties", lhs: HasDynamicProperties(dynamicProperty: 20, value: true), rhs: HasDynamicProperties(dynamicProperty: 20, value: true), expected: true),
    ("still structs with changing dynamic properties", lhs: HasDynamicProperties(dynamicProperty: 20, value: true), rhs: HasDynamicProperties(dynamicProperty: 70, value: true), expected: true),
    ("changing structs with changing dynamic properties", lhs: HasDynamicProperties(dynamicProperty: 15, value: true), rhs: HasDynamicProperties(dynamicProperty: 10, value: false), expected: false),
]

class ElementEqualsSpec: QuickSpec {
    override func spec() {
        describe("`elementEquals`") {
            for (description, lhs, rhs, expected) in elementEqualsSpecs {
                context("comparing \(description)") {
                    let ctx: (String, String) = expected ? ("when equal", "returns true") : ("when different", "returns false")

                    context(ctx.0) {
                        it(ctx.1) {
                            expect(elementEquals(lhs: lhs, rhs: rhs)).to(equal(expected))
                        }
                    }
                }
            }
        }
    }
}

@propertyWrapper
class ClassWrapped<T> {
    var wrappedValue: T

    init(wrappedValue: T) {
        self.wrappedValue = wrappedValue
    }
}

fileprivate struct ClassWrappedNonEquatableStruct {
    @ClassWrapped var val1: Bool
    @ClassWrapped var val2: Int
}

@propertyWrapper
struct StoredWrapped<T> {
    var wrappedValue: T
}

fileprivate struct StoredWrappedNonEquatableStruct {
    @StoredWrapped var val1: Bool
    @StoredWrapped var val2: Int
}

@propertyWrapper
struct ComputedWrapped<T> {
    var wrappedValue: T {
        get {
            return self.value
        }
    }

    let value: T

    init(wrappedValue: T) {
        self.value = wrappedValue
    }
}

fileprivate struct ComputedWrappedNonEquatableStruct {
    @ComputedWrapped var val1: Bool
    @ComputedWrapped var val2: Int
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

fileprivate enum UnbalancedEnum {
    case none
    case one(String)
}

struct SomeDynamicProperty: DynamicProperty, ExpressibleByIntegerLiteral {
    let dynamicValue: Int

    init(integerLiteral: Int) {
        self.dynamicValue = integerLiteral
    }

    func accept<Visitor: DynamicPropertiesVisitor>(
        visitor: Visitor,
        in property: PropertyInfo,
        target: inout Visitor.Visited,
        using context: ElementNodeContext
    ) throws {}
}

struct HasDynamicProperties {
    let dynamicProperty: SomeDynamicProperty
    let value: Bool
}
