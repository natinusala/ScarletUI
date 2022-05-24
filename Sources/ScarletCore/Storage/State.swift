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

/// Property wrapper to read and write a value managed by ScarletUI.
/// The app, scene or view body will be re-evaluated whenever a state value changes.
@propertyWrapper
public struct State<Value>: StateProperty {
    /// The state property value.
    public let value: Value

    var location: StorageLocation?

    public init(wrappedValue: Value) {
        self.value = wrappedValue
    }

    public var wrappedValue: Value {
        get {
            return value
        }
        nonmutating set {
            guard let location = self.location else {
                fatalError("Tried to set value of uninitialized state property")
            }

            location.set(value: newValue)
        }
    }

    public var anyValue: Any {
        return value
    }

    public func withValue(_ value: Any) -> Self {
        if let value = value as? Value {
            var copy = Self(wrappedValue: value)
            copy.location = self.location
            return copy
        } else {
            fatalError("Tried to set state property with value of type \(type(of: value)) (expected \(Value.self))")
        }
    }

    public func withLocation(_ location: StorageLocation) -> Self {
        var copy = self
        copy.location = location
        return copy
    }
}

extension State: Equatable where Value: Equatable {}

/// Allows accessing a state propery value in a type-erased manner.
protocol StateProperty {
    var anyValue: Any { get }
    var location: StorageLocation? { get set }

    /// Returns a copy of the property with a new value set.
    func withValue(_ value: Any) -> Self

    /// Returns a copy of the property with a new location set.
    func withLocation(_ location: StorageLocation) -> Self
}
