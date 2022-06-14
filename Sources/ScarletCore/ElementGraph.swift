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

/// Input for the `make()` function.
public struct MakeInput {
    /// Any previously stored value, if any.
    /// `nil` means that this is the first time this element is
    /// created and there is no storage for it yet.
    public let storage: StorageNode?

    /// Should state be preserved on the element?
    /// If set to `false`, the element state will be overwrote by
    /// what's currently in state storage.
    let preserveState: Bool

    public init(storage: StorageNode?, preserveState: Bool = false) {
        self.storage = storage
        self.preserveState = preserveState
    }
}

/// An operation to make on a list of dynamic elements.
public enum DynamicOperation {
    /// Insert an element at the given index.
    case insert(id: AnyHashable, at: Int)

    /// Remove element at given index.
    case remove(id: AnyHashable, at: Int)
}

/// Output of the `make()` function.
public struct MakeOutput {
    public enum Edges {
        /// Static edges. Must always have the same count.
        /// Edges can be `nil` if the node children did not change, but
        /// `count` must always be specified.
        case `static`(_: [MakeOutput?]?, count: Int)

        /// Operations to perform on the edges in case they are dynamic.
        /// Operations are applied in order, which is important to keep in mind
        /// to avoid trashing the list after insertions, removals and movements.
        case `dynamic`(operations: [DynamicOperation], viewContent: DynamicViewContent?)
    }

    /// The node kind.
    let nodeKind: ElementKind

    /// The node type.
    let nodeType: Any.Type

    /// The resulting node itself.
    /// Can be `nil` if there is nothing to store for that node
    /// or the node did not change.
    let node: ElementOutput?

    /// The resulting edges.
    let edges: Edges

    /// Proxy to make and update the element's implementation or attributes.
    /// Can be `nil` if there is no node of if the node did not change.
    let accessor: Accessor?

    public init(
        nodeKind: ElementKind,
        nodeType: Any.Type,
        node: ElementOutput?,
        edges: Edges,
        accessor: Accessor?
    ) {
        self.nodeKind = nodeKind
        self.nodeType = nodeType
        self.node = node
        self.edges = edges
        self.accessor = accessor
    }

    /// Makes a copy of that output with the edges replaced.
    public func withEdges(_ edges: Edges) -> MakeOutput {
        return MakeOutput(
            nodeKind: self.nodeKind,
            nodeType: self.nodeType,
            node: self.node,
            edges: edges,
            accessor: self.accessor
        )
    }
}

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

/// A node of the element graph.
public class ElementNode {
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

    /// Edges for this element.
    var edges: [ElementNode?]

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

        return edges.reduce(0) { $0 + ($1?.implementationsCount ?? 0) }
    }

    /// Creates a new node for the given view, making it in the process.
    public init<V: View>(parent: ElementNode?, position: Int, making view: V) {
        self.parent = parent
        self.position = position
        self.kind = .view
        self.type = V.self
        self.storage = StorageNode(for: view)
        self.edges = [ElementNode?](repeating: nil, count: V.staticEdgesCount())

        let input = MakeInput(storage: self.storage)
        let output = V.make(view: view, input: input)

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
        self.edges = [ElementNode?](repeating: nil, count: A.staticEdgesCount())

        let input = MakeInput(storage: self.storage)
        let output = A.make(app: app, input: input)

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
        edges: [ElementNode?],
        implementation: ImplementationNode?,
        implementationState: ImplementationNodeState
    ) {
        self.parent = parent
        self.position = position
        self.kind = kind
        self.type = type
        self.storage = storage
        self.edges = edges
        self.implementation = implementation
        self.implementationState = implementationState

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
    private func attachImplementationToParent() {
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
        let translatedPosition = translatedPosition + Array(0..<edgePosition).map { self.edges[$0]?.implementationsCount ?? 0 }.sum()

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
    private func detachImplementationFromParent() {
        if let implementation = self.implementation, let parent = self.parent {
            parent.detachImplementation(
                implementation,
                edgePosition: self.position,
                translatedPosition: 0
            )
        }

        self.edges.forEach { $0?.detachImplementationFromParent() }
    }

    /// Detaches the given implementation to this node's implementation, or
    /// goes up the graph to find the first parent with an implementation node.
    /// The end result is a `removeChild` call on the implementation node with the correct position.
    func detachImplementation(_ implementation: ImplementationNode, edgePosition: Int, translatedPosition: Int) {
        // Translate position: add the sum of implementations count for all edges up until this one
        // `TP = TP + I[0] + I[1] + ... + I[edgePosition - 1]` where I[X] is the count of implementations for edge X
        let translatedPosition = translatedPosition + Array(0..<edgePosition).map { self.edges[$0]?.implementationsCount ?? 0 }.sum()

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
        switch output.edges {
            case .static(let staticEdges, _):
                // Static update: update every edge one by one
                guard let staticEdges = staticEdges else { return }

                assert(
                    staticEdges.count == self.edges.count,
                    "`\(output.nodeType).make()` returned the wrong number of static edges (expected \(self.edges.count), got \(staticEdges.count))"
                )

                for idx in 0..<self.edges.count {
                    switch (self.edges[idx], staticEdges[idx]) {
                        case (.none, .none):
                            // Nothing to do
                            break
                        case (.none, .some(let newEdge)):
                            // Create a new edge
                            self.staticInsertEdge(newEdge, at: idx, attributes: attributes)
                        case (.some, .none):
                            // Remove the old edge
                            self.staticRemoveEdge(at: idx)
                        case (.some, .some(let newEdge)):
                            // Update the edge
                            self.staticUpdateEdge(at: idx, with: newEdge, attributes: attributes)
                    }
                }
            case .dynamic(let operations, let viewContent):
                guard let viewContent = viewContent else {
                    // No view content provided: assume there is nothing to do
                    return
                }

                // Dynamic update: apply every operation in order
                for operation in operations {
                    switch operation {
                        case .insert(let id, let position):
                            self.dynamicInsertEdge(at: position, identifiedBy: id, attributes: attributes, using: viewContent)
                        case .remove(let id, let position):
                            self.dynamicRemoveEdge(at: position, identifiedBy: id)
                    }
                }
        }
    }

    /// Inserts a new edge at the given index. Static variant.
    private func staticInsertEdge(_ edge: MakeOutput, at idx: Int, attributes: AttributesStash) {
        guard self.storage.edges.staticAt(idx) == nil else {
            fatalError("Tried to insert an edge on a non-empty storage node")
        }

        self.insertEdge(
            edge,
            at: idx,
            attributes: attributes,
            storageSet: { storage in
                self.storage.edges.staticSet(edge: storage, at: idx)
            }
        )
    }

    /// Inserts a new edge at the given index. Dynamic variant.
    private func dynamicInsertEdge(at idx: Int, identifiedBy id: AnyHashable, attributes: AttributesStash, using viewContent: DynamicViewContent) {
        guard self.storage.edges.dynamicAt(id: id) == nil else {
            fatalError("Tried to insert an edge on a non-empty storage node")
        }

        // Immediately get the edge output and insert it
        let input = MakeInput(storage: self.storage)
        let edge = viewContent.make(at: idx, identifiedBy: id, input: input)

        self.edges.insert(nil, at: idx)
        self.insertEdge(
            edge,
            at: idx,
            attributes: attributes,
            storageSet: { storage in
                self.storage.edges.dynamicSet(edge: storage, for: id)
            }
        )
    }

    private func insertEdge(
        _ edge: MakeOutput,
        at idx: Int,
        attributes: AttributesStash,
        storageSet: (StorageNode) -> ()
    ) {
         // Prepare the edge storage and node depending on its type
        let storageEdges: StorageNode.Edges
        let elementNodeEdges: [ElementNode?]
        switch edge.edges {
            case .static(_, let count):
                storageEdges = .static([StorageNode?](repeating: nil, count: count))
                elementNodeEdges = [ElementNode?](repeating: nil, count: count)
            case .dynamic:
                storageEdges = .dynamic([:])
                elementNodeEdges = []
        }

        // Create the storage node
        let edgeStorage = StorageNode(
            elementType: edge.nodeType,
            value: edge.node?.storage,
            edges: storageEdges
        )
        storageSet(edgeStorage)

        // Create and insert the edge node
        let edgeNode = ElementNode(
            parent: self,
            position: idx,
            kind: edge.nodeKind,
            type: edge.nodeType,
            storage: edgeStorage,
            edges: elementNodeEdges,
            implementation: edge.accessor?.makeImplementation(),
            implementationState: .creating
        )

        self.edges[idx] = edgeNode
        self.edges[idx]?.update(with: edge, attributes: attributes)
        self.edges[idx]?.attachImplementationToParent()
    }

    /// Updates edge at given position with a new edge.
    private func staticUpdateEdge(at idx: Int, with newEdge: MakeOutput, attributes: AttributesStash) {
        guard let edge = self.edges[idx] else {
            fatalError("Cannot update an edge that doesn't exist")
        }

        // If the type is the same, simply update the edge
        // otherwise remove the old one and put the new one in place
        if edge.type == newEdge.nodeType {
            edge.update(with: newEdge, attributes: attributes)
        } else {
            self.staticRemoveEdge(at: idx)
            self.staticInsertEdge(newEdge, at: idx, attributes: attributes)
        }
    }

    /// Removes edge at given position. Static version.
    private func staticRemoveEdge(at idx: Int) {
        // Detach implementation nodes
        self.edges[idx]?.detachImplementationFromParent()

        // Remove edge and discard storage
        self.edges[idx] = nil
        self.storage.edges.staticSet(edge: nil, at: idx)
    }
    /// Removes edge at given position. Dynamic version.
    private func dynamicRemoveEdge(at position: Int, identifiedBy id: AnyHashable) {
        // Detach implementation nodes
        self.edges[position]?.detachImplementationFromParent()

        // Remove edge and discard storage
        self.edges[position] = nil
        self.storage.edges.dynamicSet(edge: nil, for: id)
    }

    func printGraph(indent: Int = 0) {
        let indentString = String(repeating: " ", count: indent)
        print("\(indentString)- \(self.type): \(self.kind.displayName) (has storage: \(self.hasStorage))")

        for edge in self.edges {
            if let edge = edge {
                edge.printGraph(indent: indent + 4)
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

/// Common protocol for all "makeable" elements.
public protocol Makeable {
    func make(input: MakeInput) -> MakeOutput
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
