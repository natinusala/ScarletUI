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

public struct UpdateResult {
    let implementationPosition: Int
    let implementationCount: Int
}

/// Keeps track of a "mounted" element and its state.
///
/// The "type" of an element node is determined from how it handles its
/// edges (statically or dynamically).
public protocol ElementNode<Value>: AnyObject {
    associatedtype Value: Element

    /// Value for the element.
    var value: Value { get set }

    /// Parent of this node.
    var parent: (any ElementNode)? { get }

    /// Implementation node of this element.
    var implementation: Value.Implementation? { get }

    /// Implementation count.
    var implementationCount: Int { get set }

    /// Updates the node with a potential new version of the element.
    func updateEdges(from output: Value.Output, at implementationPosition: Int) -> UpdateResult

    /// Returns `true` if the node should be updated with the given new element
    /// (typically if it changed).
    func shouldUpdate(with element: Value) -> Bool

    /// Makes the given element.
    func make(element: Value) -> Value.Output

    /// Used to visit all edges of the node.
    /// Should only be used for debugging purposes.
    var allEdges: [(any ElementNode)?] { get }
}

extension ElementNode {
    /// Updates the node with a potential new version of the element.
    /// Returns the node implementation count.
    public func update(with element: Value, implementationPosition: Int, forced: Bool = false) -> UpdateResult {
        // Only update if required or if it's forced
        guard forced || self.shouldUpdate(with: element) else {
            return UpdateResult(
                implementationPosition: implementationPosition,
                implementationCount: self.implementationCount
            )
        }

        // Update value
        self.value = element

        // Make the element and make edges
        let output = self.make(element: element)

        // Override implementation position if the element is substantial since our edges
        // must start at 0 (the parent being ourself)

        let result = self.updateEdges(from: output, at: self.substantial ? 0 : implementationPosition)

        self.implementationCount = result.implementationCount

        // Override implementation count if the element is substantial since it has one implementation: itself
        if self.substantial {
            self.implementationCount = 1
        }

        return UpdateResult(
            implementationPosition: result.implementationPosition,
            implementationCount: self.implementationCount
        )
    }
}

extension ElementNode {
    /// Is this node substantial, aka. does it have an implementation node?
    var substantial: Bool {
        return Value.Implementation.self != Never.self
    }

    /// Attaches the implementation of this node to its parent implementation node. The implementation parent
    /// is not always the element parent (it can skip elements).
    func attachImplementationToParent(position: Int) {
        func inner(attaching implementation: ImplementationNode, at position: Int, to parentNode: any ElementNode) {
            if let parentImplementation = parentNode.implementation {
                parentImplementation.insertChild(implementation, at: position)
            } else if let parent = parentNode.parent {
                inner(attaching: implementation, at: position, to: parent)
            }
        }

        guard let implementation = self.implementation else { return }
        guard let parent = self.parent else { return }
        inner(attaching: implementation, at: position, to: parent)
    }
}

extension ElementNode {
    public func printTree(indent: Int = 0) {
        let indentStr = String(repeating: " ", count: indent)
        print("\(indentStr)- \(self.value.description)")

        self.allEdges.forEach { edge in
            if let edge {
                edge.printTree(indent: indent + 4)
            } else {
                print("\(indentStr)    - ##UNINITIALIZED##")
            }
        }
    }
}
