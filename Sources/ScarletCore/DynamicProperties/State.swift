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

protocol StateProperty<Value>: DynamicProperty {
    associatedtype Value

    var location: (any Location)? { get }

    func withLocation(_ location: any Location) -> Self
    func makeLocation(node: any StatefulElementNode) -> any Location
}

class StateLocation<Value>: Location {
    @Podable var value: Value

    unowned var node: any StatefulElementNode

    init(value: Value, node: any StatefulElementNode) {
        self.value = value
        self.node = node
    }

    func get() -> Value {
        return value
    }

    func set(_ value: Value) {
        // If the new value is the same as the current one, don't do anything
        if elementEquals(lhs: self.value, rhs: value) {
            return
        }

        self.value = value

        self.node.notifyStateChange()
    }
}

@propertyWrapper
struct State<Value>: StateProperty {
    let defaultValue: Value

    /// Location of the state value.
    /// Unowned for performances reasons and because I'm not certain
    /// ARC works well with Runtime they way it's currently used.
    /// The element node is reponsible for retaining them.
    unowned var location: (any Location<Value>)?

    var wrappedValue: Value {
        get {
            return self.location?.get() ?? self.defaultValue
        }
        nonmutating set {
            guard let location = self.location else {
                fatalError("Tried to set value on non installed state property")
            }

            location.set(newValue)
        }
    }

    init(wrappedValue: Value) {
        self.defaultValue = wrappedValue
    }

    init(defaultValue: Value, location: (any Location<Value>)?) {
        self.defaultValue = defaultValue
        self.location = location
    }

    func withLocation(_ location: any Location) -> Self {
        guard let location = location as? (any Location<Value>) else {
            fatalError("Cannot install state property: was given a location of wrong type")
        }

        return Self(
            defaultValue: self.defaultValue,
            location: location
        )
    }

    func makeLocation(node: any StatefulElementNode) -> any Location {
        return StateLocation(
            value: self.defaultValue,
            node: node
        )
    }
}


