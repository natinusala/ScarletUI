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
/// The "type" of an element node changes depending from how it handles its
/// edges (statically or dynamically, with specific behaviors...).
public protocol ElementNode<Value>: AnyObject {
    associatedtype Value: Element

    typealias Context = Value.Context

    /// Parent of this node.
    var parent: (any ElementNode)? { get }

    /// Implementation node of this element.
    var implementation: Value.Implementation? { get }

    /// Implementation count.
    var implementationCount: Int { get set }

    /// Last known values for attributes.
    /// Stored to keep a coherent context for edges when updating with no given element.
    var attributes: AttributesStash { get set }

    /// Updates the node with a new version of the element.
    ///
    /// If the output is `nil` it means the element was unchanged. Still, its edges may have changed (depending on context)
    /// so the function should still forward the update call to its edges, giving `nil` as an element.
    func updateEdges(from output: Value.Output?, at implementationPosition: Int, using context: Context) -> UpdateResult

    /// Returns `true` if the node should be updated with the given new element
    /// (typically if it changed).
    func shouldUpdate(with element: Value, using context: ElementNodeContext) -> Bool

    /// Makes the given element.
    func make(element: Value) -> Value.Output

    /// Used to visit all edges of the node.
    /// Should only be used for debugging purposes.
    var allEdges: [(any ElementNode)?] { get }

    /// Installs the view then updates it if necessary.
    func compareAndUpdate(with element: Value?, implementationPosition: Int, using context: Context) -> UpdateResult

    /// Installs the given element with the proper state and environment.
    func install(element: inout Value, using context: ElementNodeContext)

    func storeValue(_ value: Value)
    func storeContext(_ context: Context)
    func storeImplementationPosition(_ position: Int)
    var valueDebugDescription: String { get }
}

public extension ElementNode {
    /// Default implementation: always return `true` to pass through.
    func shouldUpdate(with element: Value, using context: ElementNodeContext) -> Bool {
        return true
    }

    /// Default implementation: no comparison, no installation, just update the node.
    func compareAndUpdate(with element: Value?, implementationPosition: Int, using context: Context) -> UpdateResult {
        return self.update(with: element, implementationPosition: implementationPosition, using: context)
    }

    func storeValue(_ value: Value) {}
    func storeContext(_ context: Context) {}
    func storeImplementationPosition(_ position: Int) {}

    /// Default implementation: do nothing.
    func install(element: inout Value, using context: ElementNodeContext) {}

    var valueDebugDescription: String {
        return "\(Value.self)"
    }
}

extension ElementNode {
    /// Updates the node with a new version of the element that is assumed to be different from the existing one.
    ///
    /// If the given element is `nil` it means it's unchanged. ``updateEdges(from:at:using:)`` is still called
    /// since the edges may have changed depending on context.
    ///
    /// Returns the node implementation count.
    func update(with element: Value?, implementationPosition: Int, using context: Context) -> UpdateResult {
        Logger.debug(debugImplementation, "Updating \(Value.self) with implementation position \(implementationPosition)")

        let attributes: AttributesStash

        // Update value and collect attributes
        if let element {
            self.storeValue(element)
            attributes = Value.collectAttributes(of: element)
        } else {
            attributes = self.attributes
        }

        if !attributes.isEmpty {
            Logger.debug(debugAttributes, "Collected attributes on \(Value.displayName): \(attributes.count)")
        }

        Logger.debug(debugAttributes, "Parent attributes for \(Value.displayName): \(context.attributes.count)")

        // Clear context
        let context = context
            .clearingStateChange()

        // Take the context from the parent, add our attributes
        // Then split it by implementation type to only get those we need to apply here
        // The rest will stay in the context struct given to our edges
        let (attributesToApply, edgesContext) = context
            .completingAttributes(from: attributes)
            .poppingAttributes(for: Value.Implementation.self)

        if !attributes.isEmpty {
            Logger.debug(debugAttributes, "     Attributes to apply on \(Value.displayName): \(attributesToApply.count)")
        }
        Logger.debug(debugAttributes, "Remaining attributes for \(Value.displayName)'s edges: \(edgesContext.attributes.count)")

        // Apply attributes
        for attribute in attributesToApply {
            guard let implementation = self.implementation else {
                fatalError("Invalid `ElementNode` state: expected an implementation node of type \(Value.Implementation.self) to be set")
            }

            Logger.debug(debugAttributes, "Applying attribute on \(Value.displayName)")
            attribute.anySet(on: implementation, identifiedBy: ObjectIdentifier(self))
        }

        // Make the element and make edges
        let output = element.map { self.make(element: $0) }

        // Override implementation position if the element is substantial since our edges
        // must start at 0 (the parent being ourself)

        // Update edges
        let edgesResult = self.updateEdges(
            from: output,
            at: (self.substantial ? 0 : implementationPosition),
            using: edgesContext
        )

        // Update state
        Logger.debug(debugImplementation, "Edges result of \(Value.self): \(edgesResult)")
        self.implementationCount = edgesResult.implementationCount
        self.attributes = attributes
        self.storeContext(context)
        self.storeImplementationPosition(implementationPosition)

        // Override implementation count if the element is substantial since it has ieone implementation: itself
        if self.substantial {
            self.implementationCount = 1
        }

        // Return result
        let result = UpdateResult(
            implementationPosition: implementationPosition,
            implementationCount: self.implementationCount
        )
        Logger.debug(debugImplementation, "Update result of \(Value.self): \(result)")
        return result
    }

    func compareAndUpdateAny(with element: (any Element)?, implementationPosition: Int, using context: Context) -> UpdateResult {
        let typedElement: Value?
        if let element {
            guard let element = element as? Value else {
                fatalError("Cannot update \(Value.self) with type-erased element: expected \(Value.self), got \(type(of: element))")
            }

            typedElement = element
        } else {
            typedElement = nil
        }

        return self.compareAndUpdate(with: typedElement, implementationPosition: implementationPosition, using: context)
    }
}

extension ElementNode {
    /// Is this node substantial, aka. does it have an implementation node?
    var substantial: Bool {
        return Value.Implementation.self != Never.self
    }

    /// Attaches the implementation of this node to its parent implementation node. The implementation parent
    /// is not always the element parent (it can skip elements).
    func insertImplementationInParent(position: Int) {
        func inner(attaching implementation: ImplementationNode, at position: Int, to parentNode: any ElementNode) {
            if let parentImplementation = parentNode.implementation {
                parentImplementation.insertChild(implementation, at: position)
                Logger.debug(debugImplementation, "Attaching \(Value.self) to parent \(parentImplementation.displayName) at position \(position)")
            } else if let parent = parentNode.parent {
                inner(attaching: implementation, at: position, to: parent)
            } else {
                Logger.debug(debugImplementation, "Did not find parent to attach \(Value.self) at position \(position)")
            }
        }

        guard let implementation = self.implementation else { return }
        guard let parent = self.parent else { return }

        inner(attaching: implementation, at: position, to: parent)
    }

    var parentImplementation: ImplementationNode? {
        if let parent = self.parent {
            if let implementation = parent.implementation {
                return implementation
            } else {
                return parent.parentImplementation
            }
        }

        return nil
    }

    func removeImplementationFromParent(implementationPosition: Int?) {
        // Step 1: find the parent implementation node by traversing upwards
        guard let parentImplementation = self.parentImplementation else { return }
        let implementationPosition = implementationPosition ?? 0

        // Step 2: traverse the tree downwards and remove every found implementation node
        // as every deletion offsets the position of the next node by 1, we can remove all nodes
        // in the same position as the one we're removing
        func inner(node: any ElementNode) {
            if node.implementation != nil {
                let position = implementationPosition
                Logger.debug(debugImplementation, "Removing node at position \(position) from \(parentImplementation.displayName)")
                parentImplementation.removeChild(at: position)
            } else {
                // TODO: if this is inefficient, find a way to detach all edges with direct calls
                for edge in node.allEdges {
                    if let edge {
                        inner(node: edge)
                    }
                }
            }
        }

        inner(node: self)
    }
}

extension ElementNode {
    public func printTree(displayNode: Bool = false, indent: Int = 0) {
        let nodeStr = displayNode ? " (node: \(Self.self))" : ""
        let indentStr = String(repeating: " ", count: indent)
        print("\(indentStr)- \(self.valueDebugDescription)\(nodeStr)")

        self.allEdges.forEach { edge in
            if let edge {
                edge.printTree(displayNode: displayNode, indent: indent + 4)
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
