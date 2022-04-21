
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

    return zip(lhsMirror.children, rhsMirror.children).all { (lhsChild, rhsChild) in
        anyEquals(lhs: lhsChild.value, rhs: rhsChild.value)
    }
}

// MARK: Ported from https://gist.github.com/anandabits/d9494d14fef221983ff4f1cafa318d47

/// Tries to compare `lhs` and `rhs` using an hypothetical `Equatable` conformance
/// on an unknown type. Returns `nil` if type isn't conforming to `Equatable`.
func tryEquatable(lhs: Any, rhs: Any) -> Bool? {
    /// Called by `_openExistential` with the correct LHS type.
    func receiveLHS<LHS>(_ typedLHS: LHS) -> Bool? {
        guard let typedRHS = rhs as? LHS else {
            // Both values have different types, they cannot be equal
            return false
        }

        return tryEquatable(lhs: typedLHS, rhs: typedRHS)
    }

    // This calls `receiveLHS` with `lhs` including its actual type, only known at runtime
    return _openExistential(lhs, do: receiveLHS)
}

/// Tries to compare `lhs` and `rhs` using an hypothetical `Equatable` conformance
/// on an known type. Returns `nil` if type isn't conforming to `Equatable`.
fileprivate func tryEquatable<T>(lhs: T, rhs: T) -> Bool? {
    return AreEquatablyEqual(lhs: lhs, rhs: rhs).open()
}

/// Represents a type that is possibly conforming to an existential.
/// The proxy indirection is necessary to avoid a compiler error on `receive`:
/// "Same-type requirement makes generic parameters 'T' and 'PossiblyEquatable' equivalent"
private protocol OpenerProxyProtocol {
    /// The proxied type that's possibly conforming.
    associatedtype Proxied
}
private enum OpenerProxy<Proxied>: OpenerProxyProtocol {}

/// Opens `Equatable` for the `PossiblyEquatable` proxied type.
/// If successful, uses `==` for comparison.
fileprivate struct AreEquatablyEqual<Proxy: OpenerProxyProtocol>: EquatableOpener {
    /// The type that's possibly equatable.
    typealias PossiblyEquatable = Proxy.Proxied

    let lhs: PossiblyEquatable
    let rhs: PossiblyEquatable

    init<T>(lhs: T, rhs: T) where OpenerProxy<T> == Proxy {
        self.lhs = lhs
        self.rhs = rhs
    }

    /// Called to compare both values when the type conforms to `Equatable`.
    func receive<T: Equatable>(_ equatable: T.Type) -> Bool where T == PossiblyEquatable {
        return self.lhs == self.rhs
    }
}

/// Supports recovering the `Equatable` constraint on an unconstrained generic type that is known to be
/// (or known to _possibly_ be) `Equatable` despite that information not being present in the type system.
///
/// Usage: create an instance of a conforming type and call `open()`.
///
/// - note: This is a general pattern that can be used for any constraints and is ammenable to codegen.
fileprivate protocol EquatableOpener {
    /// The type that might be `Equatable`.
    associatedtype PossiblyEquatable

    /// Receives the recovered type information and uses it to produce a `Result` when the type is known
    /// to conform to `Equatable`.
    func receive<T: Equatable>(_ equatable: T.Type) -> Bool where T == PossiblyEquatable
}

fileprivate extension EquatableOpener {
    /// Opens the values if possible then makes an `Equatable` comparison. Will return `nil` if
    /// types are not conforming to `Equatable`.
    func open() -> Bool? {
        // When this cast succeeds, we have recovered the `Equatable` conformance by using the `EquatableOpenerTrampoline`'s
        // conditional conformance to `EquatableOpenerProtocol`
        let opener = EquatableOpenerTrampoline<Self>.self as? EquatableOpenerTrampolineProtocol.Type

        // Calls down to the trampoline which calls back to `self.receive(_:)` and forwards the return value back here
        return opener?.open(self)
    }
}

fileprivate protocol EquatableOpenerTrampolineProtocol {
    // This has to be generic to avoid an associated type
    // because we need to dynamic cast in `EquatableOpener.open` above.
    static func open<Opener: EquatableOpener>(_ opener: Opener) -> Bool?
}

fileprivate enum EquatableOpenerTrampoline<Opener: EquatableOpener> {}
extension EquatableOpenerTrampoline: EquatableOpenerTrampolineProtocol where Opener.PossiblyEquatable: Equatable {
    /// - precondition: `Opener == DynamicOpener` (the method is only generic because we need to use `EquatableOpenerProtocol` as a type)
    static func open<DynamicOpener: EquatableOpener>(_ opener: DynamicOpener) -> Bool? {
        // forwards the recovered type information to the user and returns the result of using that information
        return (opener as? Opener)?.receive(Opener.PossiblyEquatable.self) as? Bool
    }
}
