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
    /// Attributes pending to be set, coming from above in the graph.
    let attributes: AttributesStash

    /// Stack of `ViewModifierContentContext` for view modifiers.
    let vmcStack: [ViewModifierContentContext]

    /// Creates a copy of the context with another VMC context pushed on the stack.
    func pushingVmcContext(_ context: ViewModifierContentContext) -> Self {
        return Self(
            attributes: self.attributes,
            vmcStack: self.vmcStack + [context]
        )
    }

    /// Creates a copy of the context with the last VMC context popped from the stack.
    func poppingVmcContext() -> (vmcContext: ViewModifierContentContext?, context: Self) {
        return (
            vmcContext: self.vmcStack.last,
            context: Self(
                attributes: self.attributes,
                vmcStack: self.vmcStack.dropLast()
            )
        )
    }

    /// Creates a copy of the context popping the attributes corresponding to the given implementation type,
    /// returning them along the context copy.
    func poppingAttributes<Implementation: ImplementationNode>(for implementationType: Implementation.Type) -> (attributes: [any AttributeSetter<Implementation>], context: Self) {
        // If we request attributes for `Never` just return empty attributes and the untouched context since
        // we can never have attributes for a `Never` implementation type.
        if Implementation.self == Never.self {
            return (
                attributes: [],
                context: self
            )
        }

        // Create a new attributes stash containing only the corresponding attributes
        // then return that, as well as a new context containing all remaining attributes
        var newStash: [any AttributeSetter<Implementation>] = []
        var remainingAttributes = AttributesStash()

        for (target, attribute) in self.attributes {
            if let attribute = attribute as? any AttributeSetter<Implementation> {
                newStash.append(attribute)

                // If the attribute needs to be propagated, put it back in the remaining attributes
                if attribute.propagate {
                    remainingAttributes[target] = attribute
                }
            } else {
                remainingAttributes[target] = attribute
            }
        }

        return (
            attributes: newStash,
            context: Self(
                attributes: remainingAttributes,
                vmcStack: self.vmcStack
            )
        )
    }

    /// Returns a copy of the context with additional attributes added.
    /// Existing attributes will not be overwritten, hence the name "completing".
    func completingAttributes(from stash: AttributesStash) -> Self {
        let newStash = stash.merging(with: self.attributes)

        return Self(
            attributes: newStash,
            vmcStack: self.vmcStack
        )
    }

    /// Returns the initial root context.
    public static func root() -> Self {
        return Self(
            attributes: AttributesStash(),
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
    func shouldUpdate(with element: Value) -> Bool

    /// Makes the given element.
    func make(element: Value) -> Value.Output

    /// Used to visit all edges of the node.
    /// Should only be used for debugging purposes.
    var allEdges: [(any ElementNode)?] { get }
}

extension ElementNode {
    /// Updates the node with a new version of the element that is assumed to be different from the existing one.
    ///
    /// If the given element is `nil` it means it's unchanged. ``updateEdges(from:at:using:)`` is still called
    /// since the edges may have changed depending on context.
    ///
    /// Returns the node implementation count.
    public func update(with element: Value?, implementationPosition: Int, using context: Context) -> UpdateResult {
        Logger.debug(debugImplementation, "Updating \(Value.self) with implementation position \(implementationPosition)")

        let attributes: AttributesStash

        // Update value and collect attributes
        if let element {
            self.value = element
            attributes = Self.collectAttributes(of: element)
        } else {
            attributes = self.attributes
        }

        // Add our attributes to the context then split it to get those we need to apply here
        // The rest will stay in the context struct given to our edges
        let (attributesToApply, context) = context
            .completingAttributes(from: attributes)
            .poppingAttributes(for: Value.Implementation.self)

        // Apply attributes
        for attribute in attributesToApply {
            guard let implementation = self.implementation else {
                fatalError("Invalid ElementNode state: expected an implementation node of type \(Value.Implementation.self) to be set")
            }

            attribute.set(on: implementation, identifiedBy: ObjectIdentifier(self))
        }

        // Make the element and make edges
        let output = element.map { self.make(element: $0) }

        // Override implementation position if the element is substantial since our edges
        // must start at 0 (the parent being ourself)

        // Update edges
        let edgesResult = self.updateEdges(
            from: output,
            at: (self.substantial ? 0 : implementationPosition),
            using: context
        )

        // Update state
        Logger.debug(debugImplementation, "Set implementation position of \(Value.self) to \(edgesResult.implementationCount)")
        self.implementationCount = edgesResult.implementationCount
        self.attributes = attributes

        // Override implementation count if the element is substantial since it has one implementation: itself
        if self.substantial {
            self.implementationCount = 1
        }

        let result = UpdateResult(
            implementationPosition: implementationPosition,
            implementationCount: self.implementationCount
        )
        Logger.debug(debugImplementation, "Update result of \(Value.self): \(result)")
        return result
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
        //       Instead, continue by checking if any subsequent node has different context
        //       and restart the update there

        var installed = element
        self.install(element: &installed)

        if self.shouldUpdate(with: installed) {
            return self.update(with: installed, implementationPosition: implementationPosition, using: context)
        } else {
            return self.update(with: nil, implementationPosition: implementationPosition, using: context)
        }
    }

    public func installAndUpdateAny(with element: (any Element)?, implementationPosition: Int, using context: Context) -> UpdateResult {
        let typedElement: Value?
        if let element {
            guard let element = element as? Value else {
                fatalError("Cannot update \(Value.self) with type-erased element: expected \(Value.self), got \(type(of: element))")
            }

            typedElement = element
        } else {
            typedElement = nil
        }

        return self.installAndUpdate(with: typedElement, implementationPosition: implementationPosition, using: context)
    }

    /// Uses a mirror to collect all attributes of the given element.
    static func collectAttributes(of element: Value) -> AttributesStash {
        let mirror = Mirror(reflecting: element)

        var attributes: AttributesStash = [:]

        for child in mirror.children {
            if let attribute = child.value as? any AttributeSetter {
                attributes[attribute.target] = attribute
            }
        }

        return attributes
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
}

extension ElementNode {
    public func printTree(displayNode: Bool = false, indent: Int = 0) {
        let nodeStr = displayNode ? " (node: \(Self.self))" : ""
        let indentStr = String(repeating: " ", count: indent)
        print("\(indentStr)- \(self.value.debugDescription)\(nodeStr)")

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
