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

// TODO: remove public everywhere once i'm done testing

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
    public let nodeKind: ElementKind

    /// The node type.
    public let nodeType: Any.Type

    /// The resulting node itself.
    /// Can be `nil` if the node did not change.
    let node: ElementOutput?

    /// Static edges of the node.
    /// Must contain exactly `staticEdgesCount` elements.
    /// Can be `nil` if the node children did not change.
    var staticEdges: [MakeOutput?]?

    /// Size of `staticEdges`, or the size it would be if `nil`.
    /// Used to create a storage node with the appropriate
    /// number of edges if `staticEdges` is `nil`.
    let staticEdgesCount: Int

    public init(
        nodeKind: ElementKind,
        nodeType: Any.Type,
        node: ElementOutput?,
        staticEdges: [MakeOutput?]?,
        staticEdgesCount: Int
    ) {
        self.nodeKind = nodeKind
        self.nodeType = nodeType
        self.node = node
        self.staticEdges = staticEdges
        self.staticEdgesCount = staticEdgesCount
    }
}

/// Output of one element in the `make()` function.
public struct ElementOutput {
    /// Any value to store and pass to the next `make()` call.
    public let storage: Any?

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

    init(elementType: Any.Type, value: Any?, edges: [StorageNode?]) {
        self.elementType = elementType
        self.value = value
        self.edges = edges
    }
}

/// A node of the element graph.
public class ElementNode {
    /// Kind of the element.
    public var kind: ElementKind

    /// Type of the element.
    var type: Any.Type

    /// Associated storage node for this element.
    let storage: StorageNode

    /// Edges for this element.
    var edges: [ElementNode?]

    var hasStorage: Bool {
        return storage.value != nil
    }

    /// Creates a new node for the given view, making it in the process.
    public init<V: View>(making view: V) {
        self.kind = .view
        self.type = V.self
        self.storage = StorageNode(for: view)
        self.edges = [ElementNode?](repeating: nil, count: V.staticEdgesCount())

        let input = MakeInput(storage: self.storage)
        self.update(with: V.make(view: view, input: input))
    }

    init(kind: ElementKind, type: Any.Type, storage: StorageNode, edges: [ElementNode?]) {
        self.kind = kind
        self.type = type
        self.storage = storage
        self.edges = edges
    }

    /// Updates the node with the given view.
    public func update<V: View>(with view: V) {
        assert(
            V.self == self.type,
            "cannot update a graph node with a view of a different type"
        )

        let input = MakeInput(storage: self.storage)
        let output = V.make(view: view, input: input)
        self.update(with: output)
    }

    /// Updates the node with the output of the given element.
    /// Can update the node data, its edges recursively or nothing at all.
    public func update(with output: MakeOutput) {
        assert(
            output.nodeType == self.type,
            "make() returned a node of the wrong type (expected \(self.type), got \(output.nodeType))"
        )

        // Node update
        if let node = output.node {
            self.type = output.nodeType
            self.storage.value = node.storage
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
                        self.insertEdge(newEdge, at: idx)
                    case (.some, .none):
                        // Remove the old edge
                        self.removeEdge(at: idx)
                    case let (.some, .some(newEdge)):
                        // Update the edge
                        self.updateEdge(at: idx, with: newEdge)
                }
            }
        }
    }

    /// Inserts a new edge at the given index.
    private func insertEdge(_ edge: MakeOutput, at idx: Int) {
        guard self.storage.edges[idx] == nil else {
            fatalError("Tried to insert an edge on a non-empty storage node")
        }

        debug("Inserting \(edge.nodeType)")

        // Create the storage node
        let edgeStorage = StorageNode(
            elementType: edge.nodeType,
            value: edge.node?.storage,
            edges: [StorageNode?](repeating: nil, count: edge.staticEdgesCount)
        )
        self.storage.edges[idx] = edgeStorage

        // Create and insert the edge node
        self.edges[idx] = ElementNode(
            kind: edge.nodeKind,
            type: edge.nodeType,
            storage: edgeStorage,
            edges: [ElementNode?](repeating: nil, count: edge.staticEdgesCount)
        )
        self.edges[idx]?.update(with: edge)
    }

    /// Updates edge at given position with a new edge.
    private func updateEdge(at idx: Int, with newEdge: MakeOutput) {
        guard let edge = self.edges[idx] else {
            fatalError("Cannot update an edge that doesn't exist")
        }

        // If the type is the same, simply update the edge
        // otherwise remove the old one and put the new one in place
        if edge.type == newEdge.nodeType {
            edge.update(with: newEdge)
        } else {
            self.removeEdge(at: idx)
            self.insertEdge(newEdge, at: idx)
        }
    }

    /// Removes edge at given position.
    private func removeEdge(at idx: Int) {
        debug("Removing \(self.edges[idx]!.type)")

        // Remove edge
        self.edges[idx] = nil

        // Discard storage
        self.storage.edges[idx] = nil
    }

    public func printGraph(indent: Int = 0) {
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
