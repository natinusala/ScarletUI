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

/// Input for the `make()` function.
public struct MakeInput {
    /// Any previously stored value, if any.
    /// `nil` means that this is the first time this element is
    /// created and there is no storage for it yet.
    public let storage: StorageNode?

    public init(storage: StorageNode?) {
        self.storage = storage
    }
}

/// Output of the `make()` function.
public struct MakeOutput {
    /// The node kind.
    let nodeKind: ElementKind

    /// The node type.
    let nodeType: Any.Type

    /// The resulting node itself.
    /// Can be `nil` if there is nothing to store for that node
    /// or the node did not change.
    let node: ElementOutput?

    /// Static edges of the node.
    /// Must contain exactly `staticEdgesCount` elements.
    /// Can be `nil` if the node children did not change.
    var staticEdges: [MakeOutput?]?

    /// Size of `staticEdges`, or the size it would be if `nil`.
    /// Used to create a storage node with the appropriate
    /// number of edges if `staticEdges` is `nil`.
    let staticEdgesCount: Int

    /// Proxy to make and update the element's implementation or attributes.
    /// Can be `nil` if there is no node of if the node did not change.
    let accessor: Accessor?

    public init(
        nodeKind: ElementKind,
        nodeType: Any.Type,
        node: ElementOutput?,
        staticEdges: [MakeOutput?]?,
        staticEdgesCount: Int,
        accessor: Accessor?
    ) {
        self.nodeKind = nodeKind
        self.nodeType = nodeType
        self.node = node
        self.staticEdges = staticEdges
        self.staticEdgesCount = staticEdgesCount
        self.accessor = accessor
    }
}

/// Output of one element in the `make()` function.
public struct ElementOutput {
    /// Any value to store and pass to the next `make()` call.
    let storage: Any?

    public init(storage: Any?) {
        self.storage = storage
    }
}

/// An element storage graph node.
public class StorageNode {
    /// Type of the element this storage node belongs to.
    public var elementType: Any.Type

    /// Node value.
    public var value: Any?

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

    /// Edges for this element.
    var edges: [ElementNode?]

    /// Implementation of this element.
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

        self.update(with: output, attributes: [])

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

        self.update(with: output, attributes: [])

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
    func update<V: View>(with view: V, attributes: [AttributeSetter]) {
        assert(
            V.self == self.type,
            "cannot update a graph node with a view of a different type"
        )

        let input = MakeInput(storage: self.storage)
        let output = V.make(view: view, input: input)
        self.update(with: output, attributes: attributes)
    }

    /// Updates the node with the output of the given element.
    /// Can update the node data, its edges recursively or nothing at all.
    func update(with output: MakeOutput, attributes: [AttributeSetter]) {
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

        // Implementation and attributes update
        if let accessor = output.accessor {
            attributes.append(contentsOf: accessor.collectAttributes())

            if let implementation = self.implementation {
                accessor.updateImplementation(implementation)

                for attribute in attributes {
                    attribute.set(on: implementation)
                }

                attributes = []

                // Call `attributesDidSet()` only at first update
                if self.implementationState == .creating {
                    implementation.attributesDidSet()
                    self.implementationState = .created
                }
            }
        }

        // Static edges update
        if let staticEdges = output.staticEdges {
            assert(
                staticEdges.count == self.edges.count,
                "`\(output.nodeType).make()` returned the wrong number of static edges (expected \(self.edges.count), got \(staticEdges.count))"
            )

            for idx in 0..<self.edges.count {
                switch (self.edges[idx], staticEdges[idx]) {
                    case (.none, .none):
                        // Nothing to do
                        break
                    case let (.none, .some(newEdge)):
                        // Create a new edge
                        self.insertEdge(newEdge, at: idx, attributes: attributes)
                    case (.some, .none):
                        // Remove the old edge
                        self.removeEdge(at: idx)
                    case let (.some, .some(newEdge)):
                        // Update the edge
                        self.updateEdge(at: idx, with: newEdge, attributes: attributes)
                }
            }
        }
    }

    /// Inserts a new edge at the given index.
    private func insertEdge(_ edge: MakeOutput, at idx: Int, attributes: [AttributeSetter]) {
        guard self.storage.edges[idx] == nil else {
            fatalError("Tried to insert an edge on a non-empty storage node")
        }

        // Create the storage node
        let edgeStorage = StorageNode(
            elementType: edge.nodeType,
            value: edge.node?.storage,
            edges: [StorageNode?](repeating: nil, count: edge.staticEdgesCount)
        )
        self.storage.edges[idx] = edgeStorage

        // Create and insert the edge node
        self.edges[idx] = ElementNode(
            parent: self,
            position: idx,
            kind: edge.nodeKind,
            type: edge.nodeType,
            storage: edgeStorage,
            edges: [ElementNode?](repeating: nil, count: edge.staticEdgesCount),
            implementation: edge.accessor?.makeImplementation(),
            implementationState: .creating
        )
        self.edges[idx]?.update(with: edge, attributes: attributes)
        self.edges[idx]?.attachImplementationToParent()
    }

    /// Updates edge at given position with a new edge.
    private func updateEdge(at idx: Int, with newEdge: MakeOutput, attributes: [AttributeSetter]) {
        guard let edge = self.edges[idx] else {
            fatalError("Cannot update an edge that doesn't exist")
        }

        // If the type is the same, simply update the edge
        // otherwise remove the old one and put the new one in place
        if edge.type == newEdge.nodeType {
            edge.update(with: newEdge, attributes: attributes)
        } else {
            self.removeEdge(at: idx)
            self.insertEdge(newEdge, at: idx, attributes: attributes)
        }
    }

    /// Removes edge at given position.
    private func removeEdge(at idx: Int) {
        // Detach implementation nodes
        self.edges[idx]?.detachImplementationFromParent()

        // Remove edge and discard storage
        self.edges[idx] = nil
        self.storage.edges[idx] = nil
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
