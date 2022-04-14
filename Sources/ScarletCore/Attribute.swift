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

/// Contains the value to give an attribute of an eventual implementation node.
///
/// The key path defines where the value is written to (the target attribute) as well
/// as the target implementation type.
///
/// The value will only be written if it's different than the current value, which makes it
/// possible to use with `didSet` observers.
///
/// TODO: remove `actualValue` and make a partial initializer once this is implemented, the point is to make it non optional: https://forums.swift.org/t/allow-property-wrappers-with-multiple-arguments-to-defer-initialization-when-wrappedvalue-is-not-specified/38319
@propertyWrapper
public struct AttributeValue<Implementation, Value>: AttributeSetter where Implementation: AnyObject, Value: Equatable {
    public typealias AttributeKeyPath = ReferenceWritableKeyPath<Implementation, Value>

    public var wrappedValue: Value {
        get {
            guard let value = self.actualValue else {
                fatalError("Cannot read attribute \(self.keyPath): it has not been set")
            }

            return value
        }
        set {
            self.actualValue = newValue
        }
    }

    public var projectedValue: Self {
        get { return self }
        set { self = newValue }
    }

    /// The attribute value.
    /// Must be optional until partial property wrappers initializers are implemented.
    var actualValue: Value?

    /// The path to the attribute in the implementation class.
    var keyPath: AttributeKeyPath

    public init(target keyPath: AttributeKeyPath) {
        self.keyPath = keyPath
    }

    /// Sets the attribute on the given implementation class.
    public func set(on implementation: Any) {
        guard let implementation = implementation as? Implementation else {
            fatalError("Attribute `set()` was given an implementation of the wrong type: got \(type(of: implementation)), expected \(Implementation.self)")
        }

        if implementation[keyPath: self.keyPath] != self.wrappedValue {
            implementation[keyPath: self.keyPath] = self.wrappedValue
        }
    }
}

/// An attribute, aka. a value from the element graph
/// passed to an implementation node.
@propertyWrapper
public struct Attribute<Value> where Value: Equatable {
    public var wrappedValue: Value

    public init(wrappedValue: Value) {
        self.wrappedValue = wrappedValue
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
