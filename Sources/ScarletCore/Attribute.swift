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
public struct AttributeValue<Implementation, Value>: AttributeSetter where Implementation: ImplementationNode, Value: Equatable {
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
    var keyPath: AttributeKeyPath

    public init(_ keyPath: AttributeKeyPath) {
        self.keyPath = keyPath
    }

    /// Sets the attribute on the given implementation class.
    public func set(on implementation: Any) {
        guard let implementation = implementation as? Implementation else {
            fatalError("Attribute `set()` was given an implementation of the wrong type: got \(type(of: implementation)), expected \(Implementation.self)")
        }

        guard case let .set(value) = self.actualValue else {
            return
        }

        if implementation[keyPath: self.keyPath] != value {
            implementation[keyPath: self.keyPath] = value
        }
    }

    /// If the element parameter is an optional value and `nil` means "attribute unset",
    /// use this convenience method to set the attribute value in one line instead of
    /// manually unwrapping the optional.
    public mutating func setFromOptional(value: Value?) {
        if let value = value {
            self.wrappedValue = value
        }
    }
}

/// An attribute, aka. a value from the element graph
/// passed to an implementation node.
///
/// The value will only be updated if it's different than the current value.
/// This includes initial initialization: as such, the default value must accurately
/// represent the _actual_ default value.
///
/// In other words, if the attribute is not set on the element, `didSet` will never be called
/// in the implementation so the default value must already be "applied" there.
@propertyWrapper
public struct Attribute<Value> where Value: Equatable {
    public var wrappedValue: Value

    public init(defaultValue: Value) {
        self.wrappedValue = defaultValue
    }
}

/// Allows collecting all attributes of an element.
public protocol AttributeAccessor {
    func collectAttributes() -> [AttributeSetter]
}

/// Sets an attribute value to any implementation.
public protocol AttributeSetter {
    /// Set the value to the given implementation.
    func set(on implementation: Any)
}

/// Collects attributes using a mirror on the given object.
public extension AttributeAccessor {
    func collectAttributesUsingMirror() -> [AttributeSetter] {
        let mirror = Mirror(reflecting: self)

        var attributes: [AttributeSetter] = []

        for child in mirror.children {
            if let attribute = child.value as? AttributeSetter {
                attributes.append(attribute)
            }
        }

        return attributes
    }
}
