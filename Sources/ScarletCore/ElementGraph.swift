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

/// Represents the value of a node in the mounted elements graph (app, scenes, views).
public struct GraphValue {
    /// The node element's type.
    var elementType: Any.Type

    /// The node element.
    var storage: AnyElement?

    /// Returns true if the element is "stored", aka if we are able
    /// to rebuild its edges by calling `makeChildren()` again.
    var stored: Bool {
        return storage != nil
    }

    public init(elementType: Any.Type, storage: ScarletCore.AnyElement? = nil) {
        self.elementType = elementType
        self.storage = storage
    }
}

/// Output of `makeChildren()`: contains static children
/// and dynamic children.
public struct ElementChildren {
    /// The static children. Must always contain as many items as
    /// what's declared in the element `staticChildrenCount` property.
    ///
    /// To remove an element, don't remove it from the list but set its value
    /// to `nil` in here instead.
    var staticChildren: [AnyElement?]

    public init(staticChildren: [AnyElement?]) {
        self.staticChildren = staticChildren
    }
}

/// A node in the mounted element graph.
public class GraphNode {
    /// The node value.
    var value: GraphValue

    /// The node edges
    var edges: [GraphNode?] = []

    /// Creates a new graph node, mounting the given value recursively until
    /// the end of the graph is reached. The element is given in case the value
    /// is a non-stored element.
    public init(mounting value: GraphValue, with element: AnyElement) {
        self.value = value

        // Run `makeChildren()` on the element to mount its static children first
        // The array will be filled with `staticChildrenCount` elements, missing children
        // will have `nil` in their position
        self.edges = element.makeChildren().staticChildren.map { child in
            if let child = child {
                return GraphNode(mounting: child.make(), with: child)
            }

            return nil
        }

        if element.staticChildrenCount != edges.count {
            fatalError("`\(element.elementType).makeChildren()` did not return exactly \(element.staticChildrenCount) static children")
        }
    }

    /// Updates the node value and re-evaluates the edges down
    /// the whole graph until no changes are found.
    public func updateValue(newValue: GraphValue, with element: AnyElement) {
        if element.elementType != self.value.elementType {
            fatalError("Cannot update value of node with type \(self.value.elementType) with \(element.elementType)")
        }

        // If we are a stored element, compare both elements to see if they are
        // the same. If they are, we can stop here. Otherwise assume elements cannot
        // be compared and always re-evaluate the edges.
        if let stored = self.value.storage {
            if anyEquals(lhs: stored, rhs: element) {
                return
            }
        }

        // Call `makeChildren()` to get the new edges list.
        // Ensure we have the right count.
        let newEdges = element.makeChildren().staticChildren

        if element.staticChildrenCount != newEdges.count {
            fatalError("`\(element.elementType).makeChildren()` did not return exactly \(element.staticChildrenCount) static children")
        }

        for idx in 0..<newEdges.count {
            switch (self.edges[idx], newEdges[idx]) {
                case (.none, .none):
                    // Nothing to do
                    break
                case let (.some, .some(new)):
                    // Update the current edge
                    self.updateEdge(at: idx, with: new)
                case (.some, .none):
                    // Remove the current edge
                    self.removeEdge(at: idx)
                case let (.none, .some(new)):
                    // Add a new edge
                    self.insertEdge(new, at: idx)
            }
        }

        self.value = newValue
    }

    /// Updates the edge at the given position with the given element.
    private func updateEdge(at idx: Int, with newElement: AnyElement) {
        guard let current = self.edges[idx] else {
            fatalError("Trying to update edge at index \(idx) but there is no edge there")
        }

        // Check edge type: if it's the same, simply update the node
        // Otherwise remove the current edge and add the new one instead.
        if newElement.elementType == current.value.elementType {
            current.updateValue(newValue: newElement.make(), with: newElement)
        } else {
            debug("Replacing edge \(self.edges[idx]!.value.elementType) at position \(idx)")

            // Remove the current edge
            self.removeEdge(at: idx)

            // Add a new edge
            self.insertEdge(newElement, at: idx)
        }
    }

    /// Removes the edge at the given position.
    private func removeEdge(at idx: Int) {
        debug("Removing edge \(self.edges[idx]!.value.elementType) at position \(idx)")
        self.edges[idx] = nil
    }

    /// Inserts a new edge at the given position.
    private func insertEdge(_ edge: AnyElement, at idx: Int) {
        debug("Inserting edge \(edge.elementType) at position \(idx)")
        self.edges[idx] = GraphNode(mounting: edge.make(), with: edge)
    }

    public func printTree(indent: Int = 0) {
        let indentStr = String(repeating: " ", count: indent)
        print("\(indentStr)- \(self.value.elementType) (stored: \(self.value.stored))")

        for edge in self.edges {
            if let edge = edge {
                edge.printTree(indent: indent + 4)
            } else {
                print("\(indentStr)    - nil")
            }
        }
    }
}

/// A graph of mounted elements (app, scenes, views).
public typealias ElementGraph = GraphNode
