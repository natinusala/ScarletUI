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

/// Output of an element's "make" method.
public struct ElementOutput {
    /// The node element.
    let element: AnyElement

    /// Should the element be stored in the resulting graph node?
    /// Only necessary if the view holds input that needs to be compared
    /// before updating the graph node (typically user views).
    let stored: Bool
}

/// Output of `makeChildren()`: contains static children
/// and dynamic children.
/// TODO: Rename to ChildrenOutput
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
    /// The node element type.
    var elementType: Any.Type

    /// The node element. Is only stored if `stored` is `true`
    /// in the element "make" output.
    var element: AnyElement?

    /// The node edges
    var edges: [GraphNode?] = []

    /// Is the element stored, aka. are we able to rebuild its children
    /// directly by calling `makeChildren()`?
    var stored: Bool {
        return self.element != nil
    }

    /// Creates a new graph node, mounting the given value recursively until
    /// the end of the graph is reached. The element is given in case the value
    /// is a non-stored element.
    public init(mounting output: ElementOutput) {
        if output.stored {
            self.element = output.element
        }
        self.elementType = output.element.elementType

        // Run `makeChildren()` on the element to mount its static children first
        // The array will be filled with `staticChildrenCount` elements, missing children
        // will have `nil` in their position
        self.edges = output.element.makeChildren().staticChildren.map { child in
            if let child = child {
                return GraphNode(mounting: child.make())
            }

            return nil
        }

        if output.element.staticChildrenCount != edges.count {
            fatalError("`\(output.element.elementType).makeChildren()` did not return exactly \(output.element.staticChildrenCount) static children")
        }
    }

    /// Updates the node and re-evaluates the edges down the whole graph until no changes are found.
    public func update(with newElement: ElementOutput) {
        if newElement.element.elementType != self.elementType {
            fatalError("Cannot update node of type \(self.elementType) with \(newElement.element.elementType)")
        }

        // If we are a stored element, compare both elements to see if they are
        // the same. If they are, we can stop here. Otherwise assume elements cannot
        // be compared and always re-evaluate the edges.
        if let stored = self.element {
            if anyEquals(lhs: stored, rhs: newElement.element) {
                return
            }
        }

        // Call `makeChildren()` to get the new edges list.
        // Ensure we have the right count.
        let newEdges = newElement.element.makeChildren().staticChildren

        if newElement.element.staticChildrenCount != newEdges.count {
            fatalError("`\(newElement.element.elementType).makeChildren()` did not return exactly \(newElement.element.staticChildrenCount) static children")
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

        // Update storage
        if newElement.stored {
            self.element = newElement.element
        } else {
            self.element = nil
        }
        self.elementType = newElement.element.elementType
    }

    /// Updates the edge at the given position with the given element.
    private func updateEdge(at idx: Int, with newElement: AnyElement) {
        guard let current = self.edges[idx] else {
            fatalError("Trying to update edge at index \(idx) but there is no edge there")
        }

        // Check edge type: if it's the same, simply update the node
        // Otherwise remove the current edge and add the new one instead.
        if newElement.elementType == current.elementType {
            current.update(with: newElement.make())
        } else {
            debug("Replacing edge \(self.edges[idx]!.elementType) at position \(idx)")

            // Remove the current edge
            self.removeEdge(at: idx)

            // Add a new edge
            self.insertEdge(newElement, at: idx)
        }
    }

    /// Removes the edge at the given position.
    private func removeEdge(at idx: Int) {
        debug("Removing edge \(self.edges[idx]!.elementType) at position \(idx)")
        self.edges[idx] = nil
    }

    /// Inserts a new edge at the given position.
    private func insertEdge(_ edge: AnyElement, at idx: Int) {
        debug("Inserting edge \(edge.elementType) at position \(idx)")
        self.edges[idx] = GraphNode(mounting: edge.make())
    }

    public func printTree(indent: Int = 0) {
        let indentStr = String(repeating: " ", count: indent)
        print("\(indentStr)- \(self.elementType) (stored: \(self.stored))")

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
