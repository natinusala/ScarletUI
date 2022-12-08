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

    public let strategy = AttributeStrategy.discard

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

    public let strategy = AttributeStrategy.append

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
                attributesLogger.trace("Appending attribute identified by \(key) on \(implementation.displayName): value is different")
                implementation[keyPath: self.keyPath].values[key] = value
            } else {
                attributesLogger.trace("Skipping appending attribute identified by \(key) on \(implementation.displayName): value hasn't changed")
            }
        } else {
            attributesLogger.trace("Appending attribute identified by \(key) on \(implementation.displayName): attribute is set for the first time")
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
public protocol AttributeSetter<Implementation>: CustomDebugStringConvertible {
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

    /// What strategy to use when applying this attribute?
    var strategy: AttributeStrategy { get }
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

    public var debugDescription: String {
        return "\(self.strategy): \(self.target)"
    }
}

/// What strategy to use when applying an attribute?
public enum AttributeStrategy {
    /// Discard the attribute if it's already been set by any parent element.
    case discard

    /// Append the attribute to the target ``AttributeList``, never discarding
    /// any value.
    case append
}

/// Represents the target key path of an attribute inside the
/// target element implementation class.
public typealias AttributeTarget = AnyKeyPath

/// An attributes "stash" holds attributes while the graph is traversed.
public struct AttributesStash {
    /// Key for one entry of the "appending" attributes dictionary.
    struct AppendKey: Hashable {
        /// Source element applying the attribute (element node object identifier hash).
        let source: AnyHashable

        /// Attribute target.
        let target: AttributeTarget
    }

    /// "Discarding" attributes are attribute with one and only one value per element.
    /// Once the value is set anywhere in the tree, it will never be overridden by children
    /// elements, making the top-most value the applied one.
    var discardingAttributes: [AttributeTarget: any AttributeSetter]

    /// "Appending" attributes are applied to a list of values on the target (``AttributeList``).
    /// Each append attribute value is bound to the source element node (usually the ``ViewAttribute`` setter)
    /// to be able to replace the correct value in the target list when it changes.
    var appendingAttributes: [AppendKey: any AttributeSetter]

    /// Creates a new attributes stash from the given list of attributes.
    init(from attributes: [AttributeTarget: any AttributeSetter], source: AnyHashable) {
        self.discardingAttributes = [:]
        self.appendingAttributes = [:]

        for (key, attribute) in attributes {
            switch attribute.strategy {
                case .discard:
                    self.discardingAttributes[key] = attribute
                case .append:
                    let key = AppendKey(source: source, target: key)
                    self.appendingAttributes[key] = attribute
            }
        }
    }

    /// Creates an empty attribute stash.
    init() {
        self.discardingAttributes = [:]
        self.appendingAttributes = [:]
    }

    /// Returns a new attributes stash containing all attributes of this stash
    /// plus all those of the given stash.
    /// Attributes from the given stash will be used if there are duplicates.
    func merging(with other: AttributesStash) -> AttributesStash {
        var newStash = self

        // Merge discarding attributes
        for (key, value) in other.discardingAttributes {
            newStash.discardingAttributes[key] = value
        }

        // Merge append attributes
        attributesLogger.trace("Appending attributes count before merging: \(newStash.appendingAttributes.count)")
        for (key, value) in other.appendingAttributes {
            newStash.appendingAttributes[key] = value
        }
        attributesLogger.trace("Appending attributes count after merging: \(newStash.appendingAttributes.count)")

        attributesLogger.trace("Total attributes count after merging: \(newStash.count)")

        return newStash
    }

    var isEmpty: Bool {
        return self.discardingAttributes.isEmpty && self.appendingAttributes.isEmpty
    }

    var count: Int {
        return self.discardingAttributes.count + self.appendingAttributes.count
    }
}

extension ElementNodeContext {
    /// Creates a copy of the context popping the attributes corresponding to the given implementation type,
    /// returning them along the context copy.
    func poppingAttributes<Implementation: ImplementationNode>(
        for implementationType: Implementation.Type
    ) -> (discarding: [any AttributeSetter], appending: [(AnyHashable, any AttributeSetter)], context: Self) {
        attributesLogger.trace("Searching for attributes to apply on \(Implementation.self)")

        // If we request attributes for `Never` just return empty attributes and the untouched context since
        // we can never have attributes for a `Never` implementation type
        if Implementation.self == Never.self {
            return (
                discarding: [],
                appending: [],
                context: self
            )
        }

        // Create a new attributes stash containing only the corresponding attributes
        // then return that, as well as a new context containing all remaining attributes
        var discardingAttributes: [any AttributeSetter] = []
        var appendingAttributes: [(AnyHashable, any AttributeSetter)] = []
        var remainingAttributes = AttributesStash()

        // Discarding attributes
        for (target, attribute) in self.attributes.discardingAttributes {
            if attribute.applies(to: implementationType) {
                attributesLogger.trace("Selected discarding attribute for applying")
                discardingAttributes.append(attribute)

                // If the attribute needs to be propagated, put it back in the remaining attributes
                if attribute.propagate {
                    attributesLogger.trace("     Discarding attribute is propagated, putting it back for the edges")
                    remainingAttributes.discardingAttributes[target] = attribute
                }
            } else {
                attributesLogger.trace("Selected discarding attribute for the edges (\(attribute.implementationType) isn't applyable on \(Implementation.self))")
                remainingAttributes.discardingAttributes[target] = attribute
            }
        }

        // Appending attributes
        for (key, attribute) in self.attributes.appendingAttributes {
            if attribute.applies(to: implementationType) {
                attributesLogger.trace("Selected appending attribute for applying")
                appendingAttributes.append((key.source, attribute))

                // If the attribute needs to be propagated, put it back in the remaining attributes
                if attribute.propagate {
                    attributesLogger.trace("     Appending attribute is propagated, putting it back for the edges")
                    remainingAttributes.appendingAttributes[key] = attribute
                }
            } else {
                attributesLogger.trace("Selected appending attribute for the edges (\(attribute.implementationType) isn't applyable on \(Implementation.self))")
                remainingAttributes.appendingAttributes[key] = attribute
            }
        }

        return (
            discarding: discardingAttributes,
            appending: appendingAttributes,
            context: Self(
                attributes: remainingAttributes,
                vmcStack: self.vmcStack,
                hasStateChanged: self.hasStateChanged,
                environment: self.environment,
                changedEnvironment: self.changedEnvironment
            )
        )
    }

    /// Returns a copy of the context with additional attributes added.
    /// Existing attributes will not be overwritten, hence the name "completing".
    func completingAttributes(from stash: AttributesStash) -> Self {
        let newStash = stash.merging(with: self.attributes)

        return Self(
            attributes: newStash,
            vmcStack: self.vmcStack,
            hasStateChanged: self.hasStateChanged,
            environment: self.environment,
            changedEnvironment: self.changedEnvironment
        )
    }
}
