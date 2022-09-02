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

public enum AttributeStorage<Value> {
    case unset
    case set(value: Value)
}

/// Contains the value to give an attribute of an eventual implementation node.
///
/// The key path defines where the value is written to (the target attribute) as well
/// as the target implementation type.
///
/// The value will only be written if it's different than the current value, which makes it
/// possible to use with `didSet` observers.
@propertyWrapper
public struct Attribute<Implementation, Value>: AttributeSetter {
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
    var actualValue: AttributeStorage<Value> = .unset

    /// The path to the attribute in the implementation class.
    let keyPath: AttributeKeyPath

    /// Should the value be propagated to every node in the graph?
    public let propagate: Bool

    /// Attribute name.
    public let identifier: AttributeIdentifier

    /// Creates a new attribute for the given `keyPath`.
    ///
    /// If `propagate` is `true`, the attribute will be propagated to all nodes in the graph
    /// even if they don't have the attribute. This is useful for attributes that should be set
    /// on the whole hierarchy if it's set on one parent node.
    public init(_ keyPath: AttributeKeyPath, propagate: Bool = false) {
        self.keyPath = keyPath
        self.propagate = propagate

        self.identifier = keyPath
    }

    /// Sets the attribute on the given implementation class.
    public func set(on implementation: Any, from node: ElementNode) -> Bool {
        // If the attribute is unset, get it over with immediately
        // Return `true` to have it removed from the stash
        guard case let .set(value) = self.actualValue else {
            return true
        }

        // If the implementation is of the wrong type, return `false` to pass it to the next node
        guard let implementation = implementation as? Implementation else {
            return false
        }

        if !anyEquals(lhs: implementation[keyPath: self.keyPath], rhs: value) {
            implementation[keyPath: self.keyPath] = value
        }

        return true
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
    public typealias Values = [ObjectIdentifier: Value]

    var values: Values = [:]

    public func makeIterator() -> Values.Values.Iterator {
        return values.values.makeIterator()
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
public struct AppendAttribute<Implementation, Value>: AttributeSetter {
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
    var actualValue: AttributeStorage<Value> = .unset

    /// The path to the attribute in the implementation class.
    let keyPath: AttributeKeyPath

    /// Should the value be propagated to every node in the graph?
    public let propagate: Bool

    /// Attribute name.
    public let identifier: AttributeIdentifier

    /// Creates a new attribute for the given `keyPath`.
    ///
    /// If `propagate` is `true`, the attribute will be propagated to all nodes in the graph
    /// even if they don't have the attribute. This is useful for attributes that should be set
    /// on the whole hierarchy if it's set on one parent node.
    public init(_ keyPath: AttributeKeyPath, propagate: Bool = false) {
        self.keyPath = keyPath
        self.propagate = propagate

        self.identifier = keyPath
    }

    /// Sets the attribute on the given implementation class.
    public func set(on implementation: Any, from node: ElementNode) -> Bool {
        // If the attribute is unset, get it over with immediately
        // Return `true` to have it removed from the stash
        guard case let .set(value) = self.actualValue else {
            return true
        }

        // If the implementation is of the wrong type, return `false` to pass it to the next node
        guard let implementation = implementation as? Implementation else {
            return false
        }

        let key = ObjectIdentifier(node)
        let list = implementation[keyPath: self.keyPath]

        // If a value exists in the node, compare it before setting
        // Otherwise just set it
        if let existingValue = list.values[key] {
            if !anyEquals(lhs: existingValue, rhs: value) {
                implementation[keyPath: self.keyPath].values[key] = value
            }
        } else {
            implementation[keyPath: self.keyPath].values[key] = value
        }

        return true
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

/// Allows collecting all attributes of an element.
public protocol AttributeAccessor {
    func collectAttributes() -> AttributesStash
}

/// Sets an attribute value to any implementation.
public protocol AttributeSetter {
    /// The attribute identifier.
    var identifier: AttributeIdentifier { get }

    /// Should the attribute be propagated to all nodes in the graph?
    var propagate: Bool { get }

    /// Set the value to the given implementation.
    /// Returns `true` if the attribute has been set.
    func set(on implementation: Any, from node: ElementNode) -> Bool
}

/// Uniquely identifies an attribute.
public typealias AttributeIdentifier = AnyKeyPath

/// An attributes "stash" holds attributes while the graph is traversed.
public typealias AttributesStash = [AttributeIdentifier: AttributeSetter]

/// Collects attributes using a mirror on the given object.
public extension AttributeAccessor {
    func collectAttributesUsingMirror() -> AttributesStash {
        let mirror = Mirror(reflecting: self)

        var attributes: AttributesStash = [:]

        for child in mirror.children {
            if let attribute = child.value as? AttributeSetter {
                attributes[attribute.identifier] = attribute
            }
        }

        return attributes
    }
}

/// A special kind of view modifiers to be used for attributes-only modifiers.
/// As attributes ownership is in the implementation, they are compared at "setting" time instead
/// of at "graph building" time. As such, they do not need to be stored in the graph nodes: this is
/// what this protocol is for.
public protocol AttributeViewModifier: ViewModifier {}

public extension AttributeViewModifier {
    /// Default implementation for `make()`: shortcut the usual modifier pattern and directly act
    /// as the VMC (except that we collect attributes).
    static func make(modifier: Self?, input: MakeInput) -> MakeOutput {
        let output = modifier.map { ElementOutput(storage: nil, attributes: $0.collectAttributes()) } 

        // Make our edge: the actual modified content from the given VMC context
        let (vmcContext, contentContext) = input.context.poppingVMCContext()

        guard let content = vmcContext.content else {
            // We don't have a content node, consider ourself unchanged
            return Self.output(
                from: input,
                node: output,
                staticEdges: nil,
                implementationPosition: input.implementationPosition,
                implementationCount: input.storage.implementationCount,
                accessor: nil
            )
        }

        // We have a content node, make it
        let contentStorage = input.storage?.edges.staticAt(0, for: vmcContext.contentType)
        let contentInput = MakeInput(
            storage: contentStorage,
            implementationPosition: input.implementationPosition,
            context: contentContext
        )

        let contentOutput = content.make(input: contentInput)

        return Self.output(
            from: input,
            node: output,
            staticEdges: [.some(contentOutput)],
            implementationPosition: input.implementationPosition,
            implementationCount: contentOutput.implementationCount,
            accessor: modifier?.accessor
        )
    }

    func body(content: Content) -> Never {
        fatalError()
    }
}
