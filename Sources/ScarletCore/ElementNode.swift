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

public protocol MakeInput<Value> {
    associatedtype Value: Element
}

public protocol MakeOutput<Value> {
    associatedtype Value: Element
}

/// Represents an element of the graph: an app, a scene or a view.
public protocol Element {
    /// Type of the state tracking node for this element.
    associatedtype Node: ElementNode<Self>

    associatedtype Input: MakeInput<Self>
    associatedtype Output: MakeOutput<Self>

    associatedtype Implementation: ImplementationNode

    /// Makes the node for that element.
    static func makeNode(of element: Self, in parent: any ElementNode, implementationPosition: Int) -> Node

    /// Makes the element, usually to get its edges.
    static func make(_ element: Self, input: Input) -> Output

    /// Returns `true` if the two given elements are equal.
    /// Used to optimize out some redundant comparisons for container elements.
    static func equals(lhs: Self, rhs: Self) -> Bool

    /// Makes the implementation node for this element.
    static func makeImplementation(of element: Self) -> Implementation?
}

extension Element where Implementation == Never {
    static func makeImplementation(of element: Self) -> Never? {
        return nil
    }
}

/// Keeps track of a "mounted" element and its state.
///
/// The "type" of an element node is determined from how it handles its
/// edges (statically or dynamically).
public protocol ElementNode<Value> {
    associatedtype Value: Element

    /// Updates the node with a potential new version of the element.
    /// Returns the node implementation count.
    func update(with element: Value, compare: Bool, implementationPosition: Int) -> Int

    /// Parent of this node.
    var parent: (any ElementNode)? { get }

    /// Implementation node of this element.
    var implementation: Value.Implementation? { get }

    /// Last known implementation position.
    var cachedImplementationPosition: Int { get }

    /// Last known implementation count.
    var cachedImplementationCount: Int { get }
}

extension ElementNode {
    /// Is this node substantial, aka. does it have an implementation node?
    var substantial: Bool {
        return Value.Implementation.self != Never.self
    }

    /// Attaches the implementation of this node to its parent implementation node. The implementation parent
    /// is not always the element parent (it can skip elements).
    func attachImplementationToParent() {
        func inner(attaching implementation: ImplementationNode, at position: Int, to parentNode: any ElementNode) {
            if let parentImplementation = parentNode.implementation {
                parentImplementation.insertChild(implementation, at: position)
            } else if let parent = parentNode.parent {
                inner(attaching: implementation, at: position, to: parent)
            }
        }

        guard let implementation = self.implementation else { return }
        guard let parent = self.parent else { return }
        inner(attaching: implementation, at: self.cachedImplementationPosition, to: parent)
    }
}
