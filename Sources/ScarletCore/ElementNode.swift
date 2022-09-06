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

/// Context given by the parent node to its edges when updating them.
public struct ElementNodeContext {
    let vmcStack: [ViewModifierContentContext]

    /// Creates a copy of the context with another VMC context pushed on the stack.
    func pushingVmcContext(_ context: ViewModifierContentContext) -> Self {
        return Self(
            vmcStack: self.vmcStack + [context]
        )
    }

    /// Creates a copy of the context with the last VMC context popped from the stack.
    func poppingVmcContext() -> (vmcContext: ViewModifierContentContext?, context: Self) {
        return (
            vmcContext: self.vmcStack.last,
            context: Self(
                vmcStack: self.vmcStack.dropLast()
            )
        )
    }

    /// Returns the initial root context.
    public static func root() -> Self {
        return Self(
            vmcStack: []
        )
    }
}

/// Keeps track of a "mounted" element and its state.
///
/// The "type" of an element node changes depending from how it handles its
/// edges (statically or dynamically, with specific behaviors...).
public protocol ElementNode<Value>: AnyObject {
    associatedtype Value: Element

    typealias Context = Value.Context

    /// Value for the element.
    var value: Value { get set }

    /// Parent of this node.
    var parent: (any ElementNode)? { get }

    /// Implementation node of this element.
    var implementation: Value.Implementation? { get }

    /// Implementation count.
    var implementationCount: Int { get set }

    /// Updates the node with a potential new version of the element.
    ///
    /// If the output is `nil` it means the element was unchanged. Still, its edges may have changed (depending on context)
    /// so the function should still forward the update call to its edges, giving `nil` as an element.
    func updateEdges(from output: Value.Output?, at implementationPosition: Int, using context: Context) -> UpdateResult

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
    ///
    /// If the given element is `nil` it means it's unchanged. ``updateEdges(from:at:using:)`` is still called
    /// since the edges may have changed depending on context.
    ///
    /// Returns the node implementation count.
    public func update(with element: Value?, implementationPosition: Int, using context: Context) -> UpdateResult {
        // Update value
        if let element {
            // Update value
            self.value = element
        }

        // Make the element and make edges
        let output = element.map { self.make(element: $0) }

        // Override implementation position if the element is substantial since our edges
        // must start at 0 (the parent being ourself)

        let result = self.updateEdges(
            from: output,
            at: (self.substantial ? 0 : implementationPosition),
            using: context
        )

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

    /// Installs the given element with the proper state and environment.
    func install(element: inout Value) {

    }

    /// Installs the view then updates it if necessary.
    public func installAndUpdate(with element: Value?, implementationPosition: Int, using context: Context) -> UpdateResult {
        // If no element is given, assume the view is unchanged so perform an update giving `nil` as element
        // TODO: Compare environment versions and if it changed, install the new environment values inside
        //       the stored value and run the update with that
        guard let element else {
            return self.update(with: nil, implementationPosition: implementationPosition, using: context)
        }

        // Otherwise, install the element and update, giving `nil` if the element is equal to the previous one
        // TODO: check if we are inside a ViewModifier - if not, there is no point to continue here.
        //       Instead, continue by checking if any subsequent node has different environment values
        //       and restart the update there

        var installed = element
        self.install(element: &installed)

        if self.shouldUpdate(with: installed) {
            return self.update(with: element, implementationPosition: implementationPosition, using: context)
        } else {
            return self.update(with: nil, implementationPosition: implementationPosition, using: context)
        }
    }

    public func installAndUpdateAny(with element: (any Element)?, implementationPosition: Int, using context: Context) -> UpdateResult {
        guard let element = element as? Value else {
            fatalError("Cannot update \(Value.self) with type-erased element: expected \(Value.self), got \(type(of: element))")
        }

        return self.installAndUpdate(with: element, implementationPosition: implementationPosition, using: context)
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
        print("\(indentStr)- \(self.value.debugDescription) (node: \(Self.self))")

        self.allEdges.forEach { edge in
            if let edge {
                edge.printTree(indent: indent + 4)
            } else {
                print("\(indentStr)    - nil")
            }
        }
    }
}

extension ElementNode {
    func nilOutputFatalError<Edge: Element>(for edge: Edge.Type) -> Never {
        fatalError("Cannot create edge \(Edge.self): given output is `nil`")
    }
}
