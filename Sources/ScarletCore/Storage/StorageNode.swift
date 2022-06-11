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
    public enum Edges {
        /// Static edges follow the same layout as the containing node.
        /// The array has a fixed size and every element in the array is fixed to one type,
        /// corresponding to one static edge.
        case `static`([StorageNode?])

        /// Dynamic edges are stored in an `ID: StorageNode` table.
        case `dynamic`([AnyHashable: StorageNode])

        /// Returns static edges or raises a fatal error if edges are of the wrong type.
        public var asStatic: [StorageNode?] {
            switch self {
                case .static(let edges):
                    return edges
                case .dynamic:
                    fatalError("Cannot convert dynamic edges to static edges")
            }
        }

        /// Returns dynamic edges or raises a fatal error if edges are of the wrong type.
        var asDynamic: [AnyHashable: StorageNode] {
            switch self {
                case .static:
                    fatalError("Cannot convert static edges to dynamic edges")
                case .dynamic(let edges):
                    return edges
            }
        }

        /// Sets the given static edge to the given value, or raises a fatal error if edges are of the wrong type.
        mutating func staticSet(edge: StorageNode?, at: Int) {
            switch self {
                case .static(var edges):
                    edges[at] = edge
                    self = .static(edges)
                case .dynamic:
                    fatalError("Cannot convert dynamic edges to static edges")
            }
        }

        /// Returns the static edge at given position or raises a fatal error if edges are of the wrong type.
        func staticAt(_ index: Int) -> StorageNode? {
            switch self {
                case .static(let edges):
                    return edges[index]
                case .dynamic:
                    fatalError("Cannot convert dynamic edges to static edges")
            }
        }

        /// Returns the dynamic edge for the given ID or raises a fatal error if edges are of the wrong type.
        func dynamicAt(id: AnyHashable) -> StorageNode? {
            switch self {
                case .static:
                    fatalError("Cannot convert static edges to dynamic edges")
                case .dynamic(let edges):
                    return edges[id]
            }
        }

        /// Sets the given dynamic edge to the given value, or raises a fatal error if edges are of the wrong type.
        mutating func dynamicSet(edge: StorageNode?, for id: AnyHashable) {
            switch self {
                case .static:
                    fatalError("Cannot convert static edges to dynamic edges")
                case .dynamic(var edges):
                    edges[id] = edge
                    self = .dynamic(edges)
            }
        }
    }

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
    public var edges: Edges

    /// Creates a new empty storage node for the given view.
    init<V: View>(for view: V) {
        self.elementType = V.self
        self.value = nil
        self.edges = .static([StorageNode?](repeating: nil, count: V.staticEdgesCount()))
    }

    /// Creates a new empty storage node for the given app.
    init<A: App>(for app: A) {
        self.elementType = A.self
        self.value = nil
        self.edges = .static([StorageNode?](repeating: nil, count: A.staticEdgesCount()))
    }

    init(elementType: Any.Type, value: Any?, edges: Edges) {
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

                    let setter: (Any) -> Void = { [offset, weak self] (value: Any) in
                        self?.setStateProperty(at: offset, value: value)
                    }

                    let location = StorageLocation(setter: setter)
                    return property.withLocation(location)
                }
            } catch {
                fatalError("Cannot setup state storage for \(elementType): \(error)")
            }
        }

        printState(of: element, at: "end of setupState(on:)")
    }

    /// Sets a state property at the given offset and trigger a body update of the element.
    func setStateProperty(at offset: Int, value: Any) {
        do {
            if var element = self.value {
                // Get property
                let elementInfo = try typeInfo(of: self.elementType)
                let statePropertyInfo = elementInfo.properties[offset]

                guard var stateProperty = try statePropertyInfo.get(from: element) as? StateProperty else {
                    fatalError("Property at offset \(offset) is not a state property")
                }

                // Mutate it to change the value
                stateProperty = stateProperty.withValue(value)

                Logger.debug(debugState, "Setting state property \(statePropertyInfo.name) to \(element)")

                // Emit a new version of our element with the state property changed
                try statePropertyInfo.set(value: stateProperty, on: &element)

                /// XXX: Swift optimizes out the `var element = self.value` copy
                /// so `stateProperty.set(value:on:)` alters both our "copy" and `self.value`
                self.value = nil

                // Fire publisher
                self.statePublisher.send(element)
            }
        } catch {
            fatalError("Cannot set property #\(offset) to \(value): \(error)")
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

/// "Location" of a dynamic property, aka. the handle used by the
/// wrapper to get the stored value and trigger a value update.
///
/// As we cannot compare closures, we redefine equality as identity
/// for this class. As such, please only create one storage location
/// per dynamic property (state, binding...) and keep it for all of its lifetime.
public class StorageLocation: Equatable {
    typealias Setter = (Any) -> Void

    let setter: Setter

    init(setter: @escaping Setter) {
        self.setter = setter
    }

    func set(value: Any) {
        self.setter(value)
    }

    public static func == (lhs: StorageLocation, rhs: StorageLocation) -> Bool {
        return rhs === lhs
    }
}
