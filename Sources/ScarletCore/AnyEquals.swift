
/*
   Copyright 2022 natinusala
   Copyright 2020 Matthew Johnson

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

/// Performs an equality check on two type-erased values.
/// This method tries its best to use the correct method with the info available at runtime
/// by testing the following methods in order:
///     1. `Equatable` conformance
///     2. `AnyClass` conformance (compare references)
///     3. Recursive field by field comparison using a `Mirror`
func anyEquals(lhs: Any, rhs: Any) -> Bool {
    // Type check
    if type(of: lhs) != type(of: rhs) {
        return false
    }

    // Consider closures as never equal
    // XXX: This is a giant hack but we can't do better until Swift
    // has some sort of a "callable" protocol
    if String(describing: type(of: lhs)).contains("->") {
        return false
    }

    // `Equatable` conformance
    if let equatableResult = tryEquatable(lhs: lhs, rhs: rhs) {
        return equatableResult
    }

    // `AnyClass` conformance
    // TODO:    Having a different reference doesn't mean the _value_ is different:
    //          if `===` returns `true` then we know it's the same, however if it returns `false` we
    //          should still compare field by field to see if the _values_ of both references are
    //          the same and prevent an useless `body` call.
    //          We should implement this optimization if we notice a lot of useless `body` calls
    //          on changing observable objects and/or on views with class property wrappers.
    if type(of: rhs) is AnyClass {
        return (lhs as AnyObject) === (rhs as AnyObject)
    }

    // Recursive field by field comparison
    let lhsMirror = Mirror(reflecting: lhs)
    let rhsMirror = Mirror(reflecting: rhs)

    // This can happen for enums with different associated values count:
    //      cases with no associated value will have 0 children, cases with associated values
    //      will have 1 child (a tuple containing all associated values), but either way the
    //      type of `lhs` and `rhs` will be the same
    if lhsMirror.children.count != rhsMirror.children.count {
        return false
    }

    return zip(lhsMirror.children, rhsMirror.children).allSatisfy { (lhsChild, rhsChild) in
        anyEquals(lhs: lhsChild.value, rhs: rhsChild.value)
    }
}

/// Tries to compare `lhs` and `rhs` using an hypothetical `Equatable` conformance
/// on an unknown type. Returns `nil` if type isn't conforming to `Equatable`.
func tryEquatable(lhs: Any, rhs: Any) -> Bool? {
    guard let lhsEquatable = lhs as? any Equatable else { return nil }
    return lhsEquatable.equals(other: rhs)
}

extension Equatable {
    func equals(other: Any) -> Bool {
        guard let other = other as? Self else { return false }
        return self == other
    }
}
