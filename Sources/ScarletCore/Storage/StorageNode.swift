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

import Foundation

import Runtime
import OpenCombine

/// An element storage graph node. Stores the app / scene / view itself as well as
/// state variables.
public class StorageNode {
    /// Type of the element this storage node belongs to.
    var elementType: Any.Type

    /// Node value, including state.
    var value: Any? {
        didSet {
            if let value = self.value {
                printState(of: value, at: "StorageNode value update")
            }
        }
    }

    /// Publisher fired when any state value changes. Gives the new
    /// version of the element (with updated state values).
    let statePublisher = PassthroughSubject<Any, Never>()

    /// Node edges.
    public var edges: [StorageNode?]

    /// Creates a new empty storage node for the given view.
    init<V: View>(for view: V) {
        self.elementType = V.self
        self.value = nil
        self.edges = [StorageNode?](repeating: nil, count: V.staticEdgesCount())
    }

    /// Creates a new empty storage node for the given app.
    init<A: App>(for app: A) {
        self.elementType = A.self
        self.value = nil
        self.edges = [StorageNode?](repeating: nil, count: A.staticEdgesCount())
    }

    init(elementType: Any.Type, value: Any?, edges: [StorageNode?]) {
        self.elementType = elementType
        self.value = value
        self.edges = edges
    }

    /// Sets up state storage on the given element.
    ///
    /// If state storage is not already setup, it will be initialized
    /// with the values currently inside the element (supposedly default values).
    ///
    /// Otherwise, stored values will be copied to the element.
    func setupState<Element: Any>(on element: inout Element) {
        if let storage = self.value {
            // If the storage node already exists, simply copy every state property
            do {
                try visitStateProperties(of: &element) { name, offset, _, metadata in
                    Logger.debug(debugState, "Copying state property \(name)")
                    return try metadata.get(from: storage)
                }
            } catch {
                fatalError("Cannot copy state for \(elementType): \(error)")
            }
        } else {
            // If the storage node does not exist, set up location for every state property
            do {
                try visitStateProperties(of: &element) { name, offset, property, _ in
                    Logger.debug(debugState, "Setting up location for state property \(name)")

                    let location = StateLocation(
                        offset: offset,
                        storageNode: self
                    )
                    return property.withLocation(location)
                }
            } catch {
                fatalError("Cannot setup state storage for \(elementType): \(error)")
            }
        }

        printState(of: element, at: "end of setupState(on:)")
    }

    /// Sets a state property at the given offset and trigger a body update of the element.
    func setStateProperty<Value>(offset: Int, property: State<Value>) {
        do {
            if var value = self.value {
                // Set property
                let elementInfo = try typeInfo(of: self.elementType)
                let stateProperty = elementInfo.properties[offset]

                Logger.debug(debugState, "Setting state property \(stateProperty.name) to \(property.value)")

                try stateProperty.set(value: property, on: &value)

                /// XXX: Swift optimizes out the `var value = self.value` copy
                /// so `stateProperty.set(value:on:)` alters both our "copy" and `self.value`
                self.value = nil

                // Fire publisher
                self.statePublisher.send(value)
            }
        } catch {
            fatalError("Cannot set property #\(offset) to \(property.value): \(error)")
        }
    }

    /// Visits state properties of the given element and runs the closure for every one of them.
    /// The state property will be replaced by the returned value if different from `nil`
    func visitStateProperties<Element: Any>(
        of element: inout Element,
        visitor: (String, Int, StateProperty, PropertyInfo) throws -> StateProperty?
    ) throws {
        let elementInfo = try typeInfo(of: Element.self)

        for (offset, property) in elementInfo.properties.enumerated() {
            if let stateValue = try property.get(from: element) as? StateProperty {
                if let newStateValue = try visitor(property.name, offset, stateValue, property) {
                    try property.set(value: newStateValue, on: &element)
                }
            }
        }
    }
}
