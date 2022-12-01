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

/// Value of an attribute setter.
public enum AttributeStorage<Value> {
    case unset
    case set(value: Value)
}

public extension Optional {
    /// Returns an unset attribute value if the optional is `nil`.
    ///
    /// Useful to have a "nil == unset" semantic on attributes that are
    /// not optional on the implementation side.
    ///
    /// An attribute "unset" through this property will not be set on the
    /// implementation node (the current value will stay). On a proper optional
    /// attribute however, the value would be overwritten to `nil` and this property
    /// wouldn't need to be used.
    var unsetIfNil: AttributeStorage<Wrapped> {
        switch self {
            case .some(let value):
                return .set(value: value)
            case .none:
                return .unset
        }
    }
}


/// Contains the value to give an attribute of an eventual implementation node.
///
/// The key path defines where the value is written to (the target attribute) as well
/// as the target implementation type.
///
/// The value will only be written if it's different than the current value, which makes it
/// possible to use with `didSet` observers.
@propertyWrapper
public struct Attribute<Implementation: ImplementationNode, Value>: AttributeSetter, IsPodable {
    public typealias AttributeKeyPath = ReferenceWritableKeyPath<Implementation, Value>

    public var wrappedValue: Value {
        get {
            fatalError("`AttributeValue` read not implemented")
        }
        set {
            self.actualValue = .set(value: newValue)
        }
    }

    public var projectedValue: Self {
        get { return self }
        set { self = newValue }
    }

    /// The attribute value.
    @Podable var actualValue: AttributeStorage<Value> = .unset

    /// The path to the attribute in the implementation class.
    let keyPath: AttributeKeyPath

    /// Should the value be propagated to every node in the graph?
    public let propagate: Bool

    public let target: AttributeTarget

    /// Creates a new attribute for the given `keyPath`.
    ///
    /// If `propagate` is `true`, the attribute will be propagated to all nodes in the graph
    /// even if they don't have the attribute. This is useful for attributes that should be set
    /// on the whole hierarchy if it's set on one parent node.
    public init(_ keyPath: AttributeKeyPath, propagate: Bool = false) {
        self.keyPath = keyPath
        self.propagate = propagate

        self.target = keyPath
    }

    /// Creates a new attribute for the given `keyPath` and initial value.
    ///
    /// If `propagate` is `true`, the attribute will be propagated to all nodes in the graph
    /// even if they don't have the attribute. This is useful for attributes that should be set
    /// on the whole hierarchy if it's set on one parent node.
    public init(_ keyPath: AttributeKeyPath, value: AttributeStorage<Value>, propagate: Bool = false) {
        self.keyPath = keyPath
        self.propagate = propagate

        self.target = keyPath

        self.actualValue = value
    }

    /// Creates a new attribute for the given `keyPath` and initial value.
    ///
    /// If `propagate` is `true`, the attribute will be propagated to all nodes in the graph
    /// even if they don't have the attribute. This is useful for attributes that should be set
    /// on the whole hierarchy if it's set on one parent node.
    public init(_ keyPath: AttributeKeyPath, value: Value, propagate: Bool = false) {
        self.init(keyPath, value: .set(value: value), propagate: propagate)
    }

    public func set(on implementation: Implementation, identifiedBy: AnyHashable) {
        // If the attribute is unset, get it over with immediately
        // Return `true` to have it removed from the stash
        guard case let .set(value) = self.actualValue else {
            return
        }

        if !elementEquals(lhs: implementation[keyPath: self.keyPath], rhs: value) {
            implementation[keyPath: self.keyPath] = value
        }
    }

    /// If the element parameter is an optional value and `nil` means "attribute unset",
    /// use this convenience method to set the attribute value in one line instead of
    /// manually unwrapping the optional.
    public mutating func setFromOptional(_ value: Value?) {
        if let value = value {
            self.wrappedValue = value
        }
    }
}

/// Used by implementation nodes to store an attribute with multiple values. Used with ``AppendAttribute``.
public struct AttributeList<Value>: Sequence {
    public typealias Values = [AnyHashable: Value]

    var values: Values = [:]

    public init() {}

    public func makeIterator() -> Values.Values.Iterator {
        return self.values.values.makeIterator()
    }

    public var isEmpty: Bool {
        return self.values.isEmpty
    }
}

/// Contains the value to append to an attribute of an eventual implementation node.
///
/// Must be used if multiple values are desired for an attribute with ``AttributeList``.
///
/// The key path defines where the value is written to (the target attribute) as well
/// as the target implementation type.
///
/// The value will only be written if it's different than the current value, which makes it
/// possible to use with `didSet` observers.
@propertyWrapper
public struct AppendAttribute<Implementation: ImplementationNode, Value>: AttributeSetter, IsPodable {
    public typealias AttributeKeyPath = ReferenceWritableKeyPath<Implementation, AttributeList<Value>>

    public var wrappedValue: Value {
        get {
            fatalError("`AttributeValue` read not implemented")
        }
        set {
            self.actualValue = .set(value: newValue)
        }
    }

    public var projectedValue: Self {
        get { return self }
        set { self = newValue }
    }

    /// The attribute value.
    @Podable var actualValue: AttributeStorage<Value> = .unset

    /// The path to the attribute in the implementation class.
    let keyPath: AttributeKeyPath

    /// Should the value be propagated to every node in the graph?
    public let propagate: Bool

    public let target: AttributeTarget

    /// Creates a new attribute for the given `keyPath`.
    ///
    /// If `propagate` is `true`, the attribute will be propagated to all nodes in the graph
    /// even if they don't have the attribute. This is useful for attributes that should be set
    /// on the whole hierarchy if it's set on one parent node.
    public init(_ keyPath: AttributeKeyPath, propagate: Bool = false) {
        self.keyPath = keyPath
        self.propagate = propagate

        self.target = keyPath
    }

    /// Creates a new attribute for the given `keyPath` and initial value.
    ///
    /// If `propagate` is `true`, the attribute will be propagated to all nodes in the graph
    /// even if they don't have the attribute. This is useful for attributes that should be set
    /// on the whole hierarchy if it's set on one parent node.
    public init(_ keyPath: AttributeKeyPath, value: AttributeStorage<Value>, propagate: Bool = false) {
        self.keyPath = keyPath
        self.propagate = propagate

        self.target = keyPath

        self.actualValue = value
    }

    /// Creates a new attribute for the given `keyPath` and initial value.
    ///
    /// If `propagate` is `true`, the attribute will be propagated to all nodes in the graph
    /// even if they don't have the attribute. This is useful for attributes that should be set
    /// on the whole hierarchy if it's set on one parent node.
    public init(_ keyPath: AttributeKeyPath, value: Value, propagate: Bool = false) {
        self.init(keyPath, value: .set(value: value), propagate: propagate)
    }

    public func set(on implementation: Implementation, identifiedBy key: AnyHashable) {
        // If the attribute is unset, get it over with immediately
        // Return `true` to have it removed from the stash
        guard case let .set(value) = self.actualValue else {
            return
        }

        let list = implementation[keyPath: self.keyPath]

        // If a value exists in the node, compare it before setting
        // Otherwise just set it
        if let existingValue = list.values[key] {
            if !elementEquals(lhs: existingValue, rhs: value) {
                attributesLogger.trace("Appending attribute identified by \(key) on \(implementation.displayName)")
                implementation[keyPath: self.keyPath].values[key] = value
            } else {
                attributesLogger.trace("Skipping appending attribute identified by \(key) on \(implementation.displayName): value hasn't changed")
            }
        } else {
            attributesLogger.trace("Appending attribute identified by \(key) on \(implementation.displayName)")
            implementation[keyPath: self.keyPath].values[key] = value
        }
    }

    /// If the element parameter is an optional value and `nil` means "attribute unset",
    /// use this convenience method to set the attribute value in one line instead of
    /// manually unwrapping the optional.
    public mutating func setFromOptional(_ value: Value?) {
        if let value = value {
            self.wrappedValue = value
        }
    }
}

/// Sets an attribute value to any implementation.
///
/// By default, attributes of an element are collected using a Mirror on the element itself
/// to gather all `@Attribute` property wrappers.
/// However this is quite slow due to the Mirror.
///
/// Using a specialized element like `ViewAttribute` without property wrappers allows collecting
/// attributes in a type-safe and faster way.
public protocol AttributeSetter<Implementation> {
    /// The implementation node type this attribute is bound to.
    associatedtype Implementation: ImplementationNode

    /// Type of the attribute value.
    associatedtype Value

    /// The attribute target.
    ///
    /// Represents the attribute key path on the implementation node side,
    /// used to identify an attribute. This is not the same as identifying an attribute
    /// *setter*, which is done with structural identity through the `identifiedBy` parameter.
    ///
    /// The value type is not necessarily ``Value`` as the
    /// attribute on the implementation side can be wrapped.
    var target: AttributeTarget { get }

    /// Should the attribute be propagated to all nodes in the graph?
    var propagate: Bool { get }

    /// Set the value to the given implementation.
    /// The identifier represents the unique element holding the attribute,
    /// using structural identity.
    func set(on implementation: Implementation, identifiedBy: AnyHashable)
}

extension AttributeSetter {
    var implementationType: any ImplementationNode.Type {
        return Implementation.self
    }

    func anySet(on implementation: Any, identifiedBy id: AnyHashable) {
        guard let implementation = implementation as? Implementation else {
            fatalError("Tried to set an attribute on the wrong implementation type: got \(type(of: implementation)), expected \(Implementation.self)")
        }

        self.set(on: implementation, identifiedBy: id)
    }

    /// Returns `true` if this attribute can be applied to the given implementation type.
    func applies(to type: any ImplementationNode.Type) -> Bool {
        return type is Implementation.Type
    }
}

/// Represents thet target key path of an attribute.
public typealias AttributeTarget = AnyKeyPath

/// An attributes "stash" holds attributes while the graph is traversed.
public typealias AttributesStash = [AttributeTarget: any AttributeSetter]

extension AttributesStash {
    /// Returns a new attributes stash containing all attributes of this stash
    /// plus all those of the given stash.
    /// Attributes from the given stash will be used if there are duplicates.
    func merging(with other: AttributesStash) -> AttributesStash {
        var newStash = self

        for (key, value) in other {
            newStash[key] = value
        }

        return newStash
    }
}
