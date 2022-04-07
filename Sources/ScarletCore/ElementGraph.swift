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
public enum MakeOutput {
    /// Output of the `make()` function in case the element changed.
    public struct Output {
        /// The resulting node itself.
        let node: ElementOutput

        /// Static edges of the node.
        /// Must contain exactly `staticEdgesCount` elements.
        let staticEdges: [MakeOutput?]

        public init(node: ElementOutput, staticEdges: [MakeOutput?]) {
            self.node = node
            self.staticEdges = staticEdges
        }
    }

    /// The element did not change compared to the
    /// stored value.
    case unchanged(type: Any.Type)

    /// The element changed compared to the stored value.
    case changed(new: Output)
}

/// Output of one element in the `make()` function.
public struct ElementOutput {
    /// The element type.
    public let type: Any.Type

    /// Any value to store and pass to the next `make()` call.
    public let storage: Any?

    public init(type: Any.Type, storage: Any?) {
        self.type = type
        self.storage = storage
    }
}

/// An element storage graph node.
public class StorageNode {
    /// Node value.
    public var value: Any?

    /// Node edges.
    public var edges: [StorageNode?]

    /// Creates a new empty storage node for the given view.
    init<V: View>(for view: V) {
        self.value = nil
        self.edges = [StorageNode?](repeating: nil, count: V.staticEdgesCount())
    }

    init(value: Any?, edges: [StorageNode?]) {
        self.value = value
        self.edges = edges
    }
}

/// A node of the element graph.
public class ElementNode {
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
        self.type = V.self
        self.storage = StorageNode.init(for: view)
        self.edges = [ElementNode?](repeating: nil, count: V.staticEdgesCount())

        let input = MakeInput(storage: self.storage)
        self.update(with: V.make(view: view, input: input))
    }

    init(type: Any.Type, storage: StorageNode, edges: [ElementNode?]) {
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
    public func update(with output: MakeOutput) {
        guard case let .changed(new) = output else {
            // Element is unchanged, nothing to do
            debug("\(self.type) is unchanged")
            return
        }

        // Update node data
        assert(
            new.node.type == self.type,
            "make() returned a node of the wrong type (expected \(self.type), got \(new.node.type))"
        )

        let node = new.node
        self.type = node.type
        self.storage.value = node.storage

        // Compare static edges one by one
        assert(
            new.staticEdges.count == self.edges.count,
            "`make()` returned the wrong number of static edges (expected \(self.edges.count), got \(new.staticEdges.count))"
        )

        for idx in 0..<self.edges.count {
            switch (self.edges[idx], new.staticEdges[idx]) {
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

    /// Inserts a new edge at the given index.
    private func insertEdge(_ edge: MakeOutput, at idx: Int) {
        guard case let .changed(new) = edge else {
            fatalError("Cannot insert an unchanged edge \(edge)")
        }

        guard self.storage.edges[idx] == nil else {
            fatalError("Tried to insert an edge on a non-empty storage node")
        }

        debug("Inserting \(new.node.type)")

        // Create the storage node if needed
        let edgeStorage = StorageNode(
            value: new.node.storage,
            edges: [StorageNode?](repeating: nil, count: new.staticEdges.count)
        )
        self.storage.edges[idx] = edgeStorage

        // Create and insert the edge node
        self.edges[idx] = ElementNode(
            type: new.node.type,
            storage: edgeStorage,
            edges: [ElementNode?](repeating: nil, count: new.staticEdges.count)
        )
        self.edges[idx]?.update(with: edge)
    }

    /// Updates edge at given position with a new edge.
    private func updateEdge(at idx: Int, with newEdge: MakeOutput) {
        guard let edge = self.edges[idx] else {
            fatalError("Cannot update an edge that doesn't exist")
        }

        edge.update(with: newEdge)
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
        print("\(indentString)- \(self.type) (has storage: \(self.hasStorage))")

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
