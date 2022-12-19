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

/// Serves as storage for state properties.
class StateLocation<Value>: Location {
    @Podable var value: Value

    weak var node: (any StatefulElementNode)?

    init(value: Value, node: any StatefulElementNode) {
        self.value = value
        self.node = node

        stateLogger.trace("Initializing a new state location")
    }

    deinit {
        stateLogger.trace("Releasing a state location")
    }

    func get() -> Value {
        return value
    }

    func set(_ value: Value) {
        guard let node else {
            fatalError("Trying to update a state value on a deinited element node")
        }

        // If the new value is the same as the current one, don't do anything
        if elementEquals(lhs: self.value, rhs: value) {
            return
        }

        self.value = value

        node.notifyStateChange()
    }
}

@propertyWrapper
public struct State<Value>: DynamicProperty {
    let defaultValue: Value
    let location: StateLocation<Value>?

    public var wrappedValue: Value {
        get {
            return self.location?.get() ?? self.defaultValue
        }
        nonmutating set {
            guard let location else {
                fatalError("Tried to set value on non installed state property")
            }

            location.set(newValue)
        }
    }

    public init(wrappedValue: Value) {
        self.defaultValue = wrappedValue
        self.location = nil
    }

    private init(defaultValue: Value, location: StateLocation<Value>?) {
        self.defaultValue = defaultValue
        self.location = location
    }

    func withLocation(_ location: StateLocation<Value>?) -> Self {
        return Self(defaultValue: self.defaultValue, location: location)
    }

    func accept<Visitor: DynamicPropertiesVisitor>(
        visitor: Visitor,
        in property: PropertyInfo,
        target: inout Visitor.Visited,
        using context: ElementNodeContext
    ) throws {
        try visitor.visitStateProperty(property, current: self, target: &target, type: Value.self)
    }
}
