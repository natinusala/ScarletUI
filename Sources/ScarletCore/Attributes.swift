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
    /// not optional on the target side.
    ///
    /// An attribute "unset" through this property will not be set on the
    /// target node (the current value will stay). On a proper optional
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

/// Sets an attribute value to any target.
///
/// By default, attributes of an element are collected using runtime metadata on the element itself
/// to gather all `@Attribute` property wrappers.
/// However this is quite slow due to runtime metadata lookup.
///
/// Using a specialized element like `ViewAttribute` without property wrappers allows collecting
/// attributes in a type-safe and faster way.
public protocol AttributeSetter<Target>: CustomDebugStringConvertible {
    /// The target node type this attribute is bound to.
    associatedtype Target

    /// Type of the attribute value.
    associatedtype Value

    /// The attribute target.
    ///
    /// Represents the attribute key path on the target node side,
    /// used to identify an attribute. This is not the same as identifying an attribute
    /// *setter*, which is done with structural identity through the `identifiedBy` parameter.
    ///
    /// The value type is not necessarily ``Value`` as the
    /// attribute on the target side can be wrapped.
    var target: AttributeTarget { get }

    /// Set the value to the given target.
    /// The identifier represents the unique element holding the attribute,
    /// using structural identity.
    func set(on target: Target, identifiedBy: AnyHashable)

    /// Adds the attribute to the given stash.
    func add(to stash: inout AttributesStash, source: AnyHashable, key: AttributeTarget)
}

/// Contains the value to give an attribute of an eventual target node.
///
/// The key path defines where the value is written to (the target property) as well
/// as the target "target node" type.
///
/// The value will only be written if it's different than the current value, which makes it
/// possible to use with `didSet` observers.
@propertyWrapper
public struct Attribute<Target, Value>: AttributeSetter, IsPodable {
    public typealias AttributeKeyPath = ReferenceWritableKeyPath<Target, Value>

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

    /// The path to the attribute in the target class.
    let keyPath: AttributeKeyPath

    public let target: AttributeTarget

    /// Creates a new attribute for the given `keyPath`.
    public init(_ keyPath: AttributeKeyPath) {
        self.keyPath = keyPath

        self.target = keyPath
    }

    /// Creates a new attribute for the given `keyPath` and initial value.
    public init(_ keyPath: AttributeKeyPath, value: AttributeStorage<Value>) {
        self.keyPath = keyPath

        self.target = keyPath

        self.actualValue = value
    }

    /// Creates a new attribute for the given `keyPath` and initial value.
    public init(_ keyPath: AttributeKeyPath, value: Value) {
        self.init(keyPath, value: .set(value: value))
    }

    public func set(on target: Target, identifiedBy: AnyHashable) {
        // If the attribute is unset, get it over with immediately
        guard case let .set(value) = self.actualValue else {
            return
        }

        if !elementEquals(lhs: target[keyPath: self.keyPath], rhs: value) {
            target[keyPath: self.keyPath] = value
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

    public func add(to stash: inout AttributesStash, source: AnyHashable, key: AttributeTarget) {
        stash.attributes[key] = self
    }
}

/// Used by target nodes to store an attribute with multiple values. Used with ``AppendAttribute``.
/// Values order is not guaranteed or meaningful since they are stored in a dictionary, keys being the originating attribute setter element nodes.
/// A convenience `Equatable` conformance is given if `Value` conforms to `Hashable` to efficiently compare the values in an unordered manner.
public struct AttributeList<Value>: Sequence, CustomStringConvertible, CustomDebugStringConvertible {
    public typealias Values = [AnyHashable: Value]

    var values: Values = [:]

    public init() {}

    public init<S>(uniqueKeysWithValues keysAndValues: S) where S : Sequence, S.Element == (Values.Key, Values.Value) {
        self.values = .init(uniqueKeysWithValues: keysAndValues)
    }

    public func makeIterator() -> Values.Values.Iterator {
        return self.values.values.makeIterator()
    }

    public var isEmpty: Bool {
        return self.values.isEmpty
    }

    public var description: String {
        return self.values.values.description
    }

    public var debugDescription: String {
        return self.values.values.debugDescription
    }
}

extension AttributeList: Equatable where Value: Equatable, Value: Hashable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        return Set(lhs.values.values) == Set(rhs.values.values)
    }
}

/// Contains the value to append to an attribute of an eventual target node.
///
/// Must be used if multiple values are desired for an attribute with ``AttributeList``.
///
/// The key path defines where the value is written to (the target property) as well
/// as the target "target node" type.
///
/// The value will only be written if it's different than the current value, which makes it
/// possible to use with `didSet` observers.
@propertyWrapper
public struct AppendAttribute<Target: TargetNode, Value>: AttributeSetter, IsPodable {
    public typealias AttributeKeyPath = ReferenceWritableKeyPath<Target, AttributeList<Value>>

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

    /// The path to the attribute in the target class.
    let keyPath: AttributeKeyPath

    public let target: AttributeTarget

    /// Creates a new attribute for the given `keyPath`.
    public init(_ keyPath: AttributeKeyPath) {
        self.keyPath = keyPath

        self.target = keyPath
    }

    /// Creates a new attribute for the given `keyPath` and initial value.
    public init(_ keyPath: AttributeKeyPath, value: AttributeStorage<Value>) {
        self.keyPath = keyPath

        self.target = keyPath

        self.actualValue = value
    }

    /// Creates a new attribute for the given `keyPath` and initial value.
    public init(_ keyPath: AttributeKeyPath, value: Value) {
        self.init(keyPath, value: .set(value: value))
    }

    public func set(on target: Target, identifiedBy key: AnyHashable) {
        // If the attribute is unset, get it over with immediately
        // Return `true` to have it removed from the stash
        guard case let .set(value) = self.actualValue else {
            return
        }

        let list = target[keyPath: self.keyPath]

        // If a value exists in the node, compare it before setting
        // Otherwise just set it
        if let existingValue = list.values[key] {
            if !elementEquals(lhs: existingValue, rhs: value) {
                attributesLogger.trace("Accumulating attribute identified by \(key) on \(target.displayName): value is different")
                target[keyPath: self.keyPath].values[key] = value
            } else {
                attributesLogger.trace("Skipping accumulating attribute identified by \(key) on \(target.displayName): value hasn't changed")
            }
        } else {
            attributesLogger.trace("Accumulating attribute identified by \(key) on \(target.displayName): attribute is set for the first time")
            target[keyPath: self.keyPath].values[key] = value
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

    public func add(to stash: inout AttributesStash, source: AnyHashable, key: AttributeTarget) {
        let key: AccumulatingAttributeKey = AccumulatingAttributeKey(source: source, target: key)
        stash.accumulatingAttributes[key] = self
    }
}

extension AttributeSetter {
    var targetType: Any.Type {
        return Target.self
    }

    func anySet(on target: Any, identifiedBy id: AnyHashable) {
        guard let target = target as? Target else {
            fatalError("Tried to set an attribute on the wrong target type: got \(type(of: target)), expected \(Target.self)")
        }

        self.set(on: target, identifiedBy: id)
    }

    /// Returns `true` if this attribute can be applied to the given target type.
    func applies(to target: any TargetNode) -> Bool {
        if let _ = target as? Target {
            return true
        }

        return false
    }

    public var debugDescription: String {
        return "\(Self.self): \(self.target)"
    }
}

/// Represents the target key path of an attribute inside the
/// target element target class.
public typealias AttributeTarget = AnyKeyPath

/// Key for one entry of the "accumulating" attributes dictionary.
struct AccumulatingAttributeKey: Hashable {
    /// Source element applying the attribute (element node object identifier hash).
    let source: AnyHashable

    /// Attribute target.
    let target: AttributeTarget
}

/// An attributes "stash" holds attributes while the graph is traversed.
public struct AttributesStash {
    /// Regular attributes are attribute with one and only one value per element.
    /// Once the value is set anywhere in the tree, it will never be overridden by children
    /// elements, making the top-most value the applied one (parent takes precedence).
    /// TODO: should we reverse this as this is inconsistent with environment values?
    var attributes: [AttributeTarget: any AttributeSetter]

    /// "Accumulating" attributes are applied to a list of values on the target (``AttributeList``).
    /// Each append attribute value is bound to the source element node (usually the ``ViewAttribute`` setter)
    /// to be able to replace the correct value in the target list when it changes.
    var accumulatingAttributes: [AccumulatingAttributeKey: any AttributeSetter]

    /// Creates a new attributes stash from the given list of attributes.
    init(from attributes: [AttributeTarget: any AttributeSetter], source: AnyHashable) {
        self.attributes = [:]
        self.accumulatingAttributes = [:]

        for (key, attribute) in attributes {
            attribute.add(to: &self, source: source, key: key)
        }
    }

    /// Creates an empty attribute stash.
    init() {
        self.attributes = [:]
        self.accumulatingAttributes = [:]
    }

    /// Returns a new attributes stash containing all attributes of this stash
    /// plus all those of the given stash.
    /// Attributes from the given stash will be used if there are duplicates.
    func merging(with other: AttributesStash) -> AttributesStash {
        var newStash = self

        // Merge attributes
        for (key, value) in other.attributes {
            newStash.attributes[key] = value
        }

        // Merge accumulating attributes
        attributesLogger.trace("Accumulating attributes count before merging: \(newStash.accumulatingAttributes.count)")
        for (key, value) in other.accumulatingAttributes {
            newStash.accumulatingAttributes[key] = value
        }
        attributesLogger.trace("Accumulating attributes count after merging: \(newStash.accumulatingAttributes.count)")

        attributesLogger.trace("Total attributes count after merging: \(newStash.count)")

        return newStash
    }

    var isEmpty: Bool {
        return self.attributes.isEmpty && self.accumulatingAttributes.isEmpty
    }

    var count: Int {
        return self.attributes.count + self.accumulatingAttributes.count
    }
}

extension ElementNodeContext {
    /// Creates a copy of the context popping the attributes corresponding to the given target type,
    /// returning them along the context copy.
    func poppingAttributes<Target: TargetNode>(
        for target: Target?
    ) -> (attributes: [any AttributeSetter], accumulating: [(AnyHashable, any AttributeSetter)], context: Self) {
        attributesLogger.trace("Searching for attributes to apply on \(Target.self)")

        // If we request attributes for `Never` just return empty attributes and the untouched context since
        // we can never have attributes for a `Never` target type
        if Target.self == Never.self {
            return (
                attributes: [],
                accumulating: [],
                context: self
            )
        }

        // Create a new attributes stash containing only the corresponding attributes
        // then return that, as well as a new context containing all remaining attributes
        var attributes: [any AttributeSetter] = []
        var accumulatingAttributes: [(AnyHashable, any AttributeSetter)] = []
        var remainingAttributes = AttributesStash()

        // Attributes
        for (attributeTarget, attribute) in self.attributes.attributes {
            if target.map({ attribute.applies(to: $0) }) ?? false {
                attributesLogger.trace("Selected attribute for applying")
                attributes.append(attribute)
            } else {
                attributesLogger.trace("Selected attribute for the edges (\(attribute.targetType) isn't applyable on \(Target.self))")
                remainingAttributes.attributes[attributeTarget] = attribute
            }
        }

        // Accumulating attributes
        for (key, attribute) in self.attributes.accumulatingAttributes {
            if target.map({ attribute.applies(to: $0) }) ?? false {
                attributesLogger.trace("Selected accumulating attribute for applying")
                accumulatingAttributes.append((key.source, attribute))
            } else {
                attributesLogger.trace("Selected accumulating attribute for the edges (\(attribute.targetType) isn't applyable on \(Target.self))")
                remainingAttributes.accumulatingAttributes[key] = attribute
            }
        }

        return (
            attributes: attributes,
            accumulating: accumulatingAttributes,
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
