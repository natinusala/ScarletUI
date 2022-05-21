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

    var location: StateLocation?

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

            location.setStateProperty(self, value: newValue)
        }
    }

    public var anyValue: Any {
        return value
    }

    /// Makes a copy of the state property with a different value.
    /// Keeps location unchanged.
    func withValue(_ value: Value) -> Self {
        var state = State(wrappedValue: value)
        state.location = self.location
        return state
    }
}

/// Allows accessing a state propery value in a type-erased manner.
protocol StateProperty {
    var anyValue: Any { get }
    var location: StateLocation? { get set }
}

extension StateProperty {
    func withLocation(_ location: StateLocation) -> StateProperty {
        var copy = self
        copy.location = location
        return copy
    }
}

/// "Location" of a state property, aka. the handle used by the
/// wrapper to trigger a value update.
struct StateLocation {
    /// The state property offset inside the element.
    let offset: Int

    /// The storage node containing the element.
    let storageNode: StorageNode

    func setStateProperty<Value>(_ stateProperty: State<Value>, value: Value) {
        // Create a copy of the state property with the new value and store it
        let newProperty = stateProperty.withValue(value)
        self.storageNode.setStateProperty(offset: self.offset, property: newProperty)
    }
}
