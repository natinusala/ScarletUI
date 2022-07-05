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

/// Output of one element in the `make()` function.
public struct ElementOutput {
    /// Any value to store and pass to the next `make()` call.
    let storage: Any?

    /// Attributes for this node.
    /// Will be set to the first encountered
    /// implementation node.
    let attributes: AttributesStash

    public init(storage: Any?, attributes: AttributesStash) {
        self.storage = storage
        self.attributes = attributes
    }
}

/// An edge of a dynamic view.
class DynamicEdge {
    /// The node of the edge. `nil` means it's not been created yet.
    var node: ElementNode?

    /// The associated identifier to this edge.
    let id: AnyHashable

    init(id: AnyHashable) {
        self.id = id
    }
}

/// A node of the element graph.
public class ElementNode {
    enum Edge {
        /// Static edge.
        /// `nil` means the view has been removed from the slot (optional view).
        case `static`(ElementNode?)

        // Dynamic edge.
        case `dynamic`(DynamicEdge)

        var node: ElementNode? {
            switch self {
            case .static(let node):
                return node
            case .dynamic(let edge):
                return edge.node
            }
        }
    }

    /// The parent of this node.
    var parent: ElementNode?

    /// Position of this node in the parent's edges list.
    var position: Int

    /// Kind of the element.
    var kind: ElementKind

    /// Type of the element.
    var type: Any.Type

    /// Associated storage node for this element.
    let storage: StorageNode

    /// Subscription for the storage node, fired whenever
    /// a state value changes.
    var storageSubscription: AnyCancellable?

    /// The edges adapter for this node.
    let edgesAdapter: any EdgesAdapter

    /// Edges for this element.
    var edges: [Edge]

    /// Implementation of this element.
    /// Public to allow the implementation to run the app node.
    public let implementation: ImplementationNode?

    /// Current state of the implementation node.
    var implementationState: ImplementationNodeState

    /// Is this element substantial, aka. does it exist onscreen?
    var substantial: Bool {
        return implementation != nil
    }

    /// Does this element have a storage node?
    var hasStorage: Bool {
        return storage.value != nil
    }

    /// Returns the number of implementations nodes this element and its edges have.
    /// TODO: cache this value instead of requiring a full traversal each time
    var implementationsCount: Int {
        if self.implementation != nil {
            return 1
        }

        return edges.reduce(0) { $0 + ($1.node?.implementationsCount ?? 0) }
    }

    /// Creates a new node for the given view, making it in the process.
    public init<V: View>(parent: ElementNode?, position: Int, making view: V) {
        self.parent = parent
        self.position = position
        self.kind = .view
        self.type = V.self
        self.storage = StorageNode(for: view)
        self.edges = [Edge](repeating: .static(nil), count: V.staticEdgesCount)

        let input = MakeInput(storage: self.storage)
        let output = V.make(view: view, input: input)

        self.edgesAdapter = makeEdgesAdapter(for: output)

        self.implementation = output.accessor?.makeImplementation()
        self.implementationState = .creating

        self.subscribeToStateChanges()

        self.update(with: output, attributes: [:])

        self.attachImplementationToParent()
    }

    /// Creates a new node for the given app, making it in the process.
    public init<A: App>(parent: ElementNode?, position: Int, making app: A) {
        self.parent = parent
        self.position = position
        self.kind = .app
        self.type = A.self
        self.storage = StorageNode(for: app)
        self.edges = [Edge](repeating: .static(nil), count: A.staticEdgesCount)

        let input = MakeInput(storage: self.storage)
        let output = A.make(app: app, input: input)

        self.edgesAdapter = makeEdgesAdapter(for: output)

        self.implementation = output.accessor?.makeImplementation()
        self.implementationState = .creating

        self.subscribeToStateChanges()

        self.update(with: output, attributes: [:])

        self.attachImplementationToParent()
    }

    init(
        parent: ElementNode?,
        position: Int,
        kind: ElementKind,
        type: Any.Type,
        storage: StorageNode,
        edges: [Edge],
        implementation: ImplementationNode?,
        implementationState: ImplementationNodeState,
        edgesAdapter: any EdgesAdapter
    ) {
        self.parent = parent
        self.position = position
        self.kind = kind
        self.type = type
        self.storage = storage
        self.edges = edges
        self.implementation = implementation
        self.implementationState = implementationState
        self.edgesAdapter = edgesAdapter

        self.subscribeToStateChanges()
    }

    private func subscribeToStateChanges() {
        self.storageSubscription = self.storage.statePublisher.sink { element in
            if let makeable = element as? Makeable {
                Logger.debug(debugState, "\(self.type) state value changed, re-evaluating body")

                printState(of: element, at: "state change sink (new element)")

                // Make the element preserving state - the version we get from the publisher
                // already has the most up-to-date values vor every property
                let input = MakeInput(storage: self.storage, preserveState: true)
                let output = makeable.make(input: input)

                self.update(with: output, attributes: [:])
            } else {
                fatalError("Cannot re-evaluate body of \(self.type): does not conform to `Makeable`")
            }
        }
    }

    /// Attaches this node's implementation node to the parent, if any.
    /// Must be called when creating a new element node, after fully populating its edges.
    func attachImplementationToParent() {
        if let implementation = self.implementation, let parent = self.parent {
            parent.attachImplementation(
                implementation,
                edgePosition: self.position,
                translatedPosition: 0
            )
        }
    }

    /// Attaches the given implementation to this node's implementation, or
    /// goes up the graph to find the first parent with an implementation node.
    /// The end result is an `insertChild` call on the implementation node with the correct position.
    func attachImplementation(_ implementation: ImplementationNode, edgePosition: Int, translatedPosition: Int) {
        // Translate position: add the sum of implementations count for all edges up until this one
        // `TP = TP + I[0] + I[1] + ... + I[edgePosition - 1]` where I[X] is the count of implementations for edge X
        let translatedPosition = translatedPosition + Array(0..<edgePosition).map { self.edges[$0].node?.implementationsCount ?? 0 }.sum()

        // If we have an implementation node, insert it directly
        // Otherwise pass it to the parent
        if let parentImplementation = self.implementation {
            parentImplementation.insertChild(implementation, at: translatedPosition)
        } else {
            self.parent?.attachImplementation(
                implementation,
                edgePosition: self.position,
                translatedPosition: translatedPosition
            )
        }
    }

    /// Traverses the graph, finds and detaches every implementation node.
    func detachImplementationFromParent() {
        if let implementation = self.implementation, let parent = self.parent {
            parent.detachImplementation(
                implementation,
                edgePosition: self.position,
                translatedPosition: 0
            )
        }

        self.edges.forEach { $0.node?.detachImplementationFromParent() }
    }

    /// Detaches the given implementation to this node's implementation, or
    /// goes up the graph to find the first parent with an implementation node.
    /// The end result is a `removeChild` call on the implementation node with the correct position.
    func detachImplementation(_ implementation: ImplementationNode, edgePosition: Int, translatedPosition: Int) {
        // Translate position: add the sum of implementations count for all edges up until this one
        // `TP = TP + I[0] + I[1] + ... + I[edgePosition - 1]` where I[X] is the count of implementations for edge X
        let translatedPosition = translatedPosition + Array(0..<edgePosition).map { self.edges[$0].node?.implementationsCount ?? 0 }.sum()

        // If we have an implementation node, insert it directly
        // Otherwise pass it to the parent
        if let parentImplementation = self.implementation {
            parentImplementation.removeChild(at: translatedPosition)
        } else {
            self.parent?.detachImplementation(
                implementation,
                edgePosition: self.position,
                translatedPosition: translatedPosition
            )
        }
    }

    /// Updates the node with the given view.
    func update<V: View>(with view: V, attributes: AttributesStash) {
        assert(
            V.self == self.type,
            "cannot update a graph node with a view of a different type"
        )

        let input = MakeInput(storage: self.storage)
        let output = V.make(view: view, input: input)
        self.update(with: output, attributes: attributes)
    }

    /// Updates the node with the given app.
    public func update<A: App>(with app: A, attributes: AttributesStash) {
        assert(
            A.self == self.type,
            "cannot update a graph node with an app of a different type"
        )

        let input = MakeInput(storage: self.storage)
        let output = A.make(app: app, input: input)
        self.update(with: output, attributes: attributes)
    }

    /// Updates the node with the output of the given element.
    /// Can update the node data, its edges recursively or nothing at all.
    func update(with output: MakeOutput, attributes: AttributesStash) {
        assert(
            output.nodeType == self.type,
            "make() returned a node of the wrong type (expected \(self.type), got \(output.nodeType))"
        )

        var attributes = attributes // make mutable

        // Node update
        if let node = output.node {
            self.type = output.nodeType
            self.storage.value = node.storage
        }

        // Implementation update
        if let accessor = output.accessor, let implementation = self.implementation {
            accessor.updateImplementation(implementation)
        }

        // Attributes updates
        let newAttributes = output.node?.attributes ?? [:]
        newAttributes.forEach { attributes[$0] = $1 }

        if let implementation = self.implementation {
            attributes = attributes.filter {
                let set = $1.set(on: implementation)
                let propagate = $1.propagate

                // Remove it from the stash if it's been set and if it's not propagated
                return !set || propagate
            }

            // Call `attributesDidSet()` only at first update
            if self.implementationState == .creating {
                implementation.attributesDidSet()
                self.implementationState = .created
            }
        }

        // Edges update
        self.edgesAdapter.updateEdges(
            output.edges,
            of: output,
            in: self,
            attributes: attributes
        )
    }

    /// Creates both storage node edges and element node edges for a given edge to insert.
    func prepareEdgesForEdge(_ edge: MakeOutput) -> (StorageNode.Edges, [Edge]) {
        let storageEdges: StorageNode.Edges
        let elementNodeEdges: [Edge]
        switch edge.edges {
            case .static(_, let count):
                storageEdges = .static([StorageNode?](repeating: nil, count: count))
                elementNodeEdges = [Edge](repeating: .static(nil), count: count)
            case .dynamic:
                storageEdges = .dynamic([:])
                elementNodeEdges = []
        }

        return (storageEdges, elementNodeEdges)
    }

    func printGraph(indent: Int = 0) {
        let indentString = String(repeating: " ", count: indent)
        print("\(indentString)- \(self.type): \(self.kind.displayName) (has storage: \(self.hasStorage))")

        for edge in self.edges {
            if let node = edge.node {
                node.printGraph(indent: indent + 4)
            } else {
                print("\(indentString)    - <nil>")
            }
        }
    }
}

/// An element graph.
public typealias ElementGraph = ElementNode

/// Kind of an element in the graph.
public enum ElementKind {
    case app
    case scene
    case view
    case viewModifier

    var displayName: String {
        switch self {
            case .app: return "App"
            case .scene: return "Scene"
            case .view: return "View"
            case .viewModifier: return "ViewModifier"
        }
    }
}

public typealias Accessor = ImplementationAccessor & AttributeAccessor

/// Different states of an implementation node.
public enum ImplementationNodeState {
    /// The node is being created and attributes are being set.
    case creating

    /// The node is fully created and all attributes are set.
    case created
}

func printState(of element: @autoclosure () -> Any, at prefix: String) {
    guard debugState else { return }

    let element = element()
    let type = Swift.type(of: element)

    Logger.debug(debugState, "State of \(type) at \(prefix):")

    let elementInfo = try? typeInfo(of: type)
    for property in elementInfo?.properties ?? [] {
        if let stateProperty = try? property.get(from: element) as? StateProperty {
            Logger.debug(debugState, "      - \(property.name): \(stateProperty.anyValue) (initialized: \(stateProperty.location != nil))")
        }
    }
}
