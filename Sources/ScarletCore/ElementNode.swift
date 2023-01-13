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
    let targetPosition: Int
    let targetCount: Int
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

    /// Target node of this element.
    var target: Value.Target? { get }

    /// Target count.
    var targetCount: Int { get set }

    /// Last known values for attributes.
    /// Stored to keep a coherent context for edges when updating with no given element.
    var attributes: AttributesStash { get set }

    /// Updates the node with a new version of the element.
    ///
    /// If the output is `nil` it means the element was unchanged. Still, its edges may have changed (depending on context)
    /// so the function should still forward the update call to its edges, giving `nil` as an element.
    func updateEdges(from output: Value.Output?, at targetPosition: Int, using context: Context) -> UpdateResult

    /// Returns `true` if the node should be updated with the given new element
    /// (typically if it changed).
    func shouldUpdate(with element: Value, using context: ElementNodeContext) -> Bool

    /// Makes the given element.
    func make(element: Value) -> Value.Output

    /// Used to visit all edges of the node.
    /// Should only be used for debugging purposes.
    var allEdges: [(any ElementNode)?] { get }

    /// Installs the view then updates it if necessary.
    func compareAndUpdate(with element: Value?, targetPosition: Int, using context: Context) -> UpdateResult

    /// Installs the given element with the proper state and environment.
    func install(element: inout Value, using context: ElementNodeContext)

    /// Takes the previous environment values and compares them with the new ones.
    /// Returns a new environment storage as well as the list of all changed key paths.
    func compareEnvironment(of element: Value, using context: ElementNodeContext) -> (values: EnvironmentValues, changed: EnvironmentDiff)

    /// Takes the given environment diff and sets environment values of this node to `false`, if any.
    func resetEnvironmentDiff(from diff: EnvironmentDiff) -> EnvironmentDiff

    func storeValue(_ value: Value)
    func storeContext(_ context: Context)
    func storeTargetPosition(_ position: Int)
    var valueDebugDescription: String { get }
}

public extension ElementNode {
    /// Default implementation: always return `true` to pass through.
    func shouldUpdate(with element: Value, using context: ElementNodeContext) -> Bool {
        return true
    }

    /// Default implementation: no comparison, no installation, just update the node.
    func compareAndUpdate(with element: Value?, targetPosition: Int, using context: Context) -> UpdateResult {
        return self.update(with: element, targetPosition: targetPosition, using: context)
    }

    /// Default implementation: this is not an environment node, don't reset anything.
    func resetEnvironmentDiff(from diff: EnvironmentDiff) -> EnvironmentDiff {
        return diff
    }

    func storeValue(_ value: Value) {}
    func storeContext(_ context: Context) {}
    func storeTargetPosition(_ position: Int) {}

    /// Default implementation: do nothing.
    func install(element: inout Value, using context: ElementNodeContext) {}

    /// Default implementation: return the same environment storage.
    func compareEnvironment(of element: Value, using context: ElementNodeContext) -> (values: EnvironmentValues, changed: EnvironmentDiff) {
        return (values: context.environment, changed: context.changedEnvironment)
    }

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
    /// Returns the node target count.
    public func update(with element: Value?, targetPosition: Int, using context: Context, initial: Bool = false) -> UpdateResult {
        targetLogger.trace("Updating \(Value.self) with target position \(targetPosition)")

        let attributes: AttributesStash
        let environment: EnvironmentValues
        let changedEnvironment: EnvironmentDiff

        // Update value, collect attributes and environment
        if let element {
            self.storeValue(element)

            let source = ObjectIdentifier(self)
            attributesLogger.trace("Collecting attributes of \(Self.Value.self.displayName) using source \(source)")
            attributes = Value.collectAttributes(of: element, source: source)

            environmentLogger.trace("Comparing environment of \(Value.self)")
            (environment, changedEnvironment) = self.compareEnvironment(of: element, using: context)
        } else {
            attributes = self.attributes
            environment = context.environment

            // Only applies when this is an environment node:
            // When there is no element, assume the environment value to be unchanged compared to the previous
            // value so reset the diff
            changedEnvironment = self.resetEnvironmentDiff(from: context.changedEnvironment)

            environmentLogger.trace("Not comparing environment of \(Value.self): element is unchanged")
        }

        if !attributes.isEmpty {
            attributesLogger.trace("Collected attributes on \(Value.displayName): \(attributes.count)")
        }

        attributesLogger.trace("Parent attributes for \(Value.displayName): \(context.attributes.count)")

        // Clear context
        let context = context
            .clearingStateChange()

        // Take the context from the parent, add our attributes
        // Then split it by target type to only get those we need to apply here
        // The rest will stay in the context struct given to our edges
        let (singleAttributes, accumulatingAttributes, edgesContext) = context
            .completingAttributes(from: attributes)
            .withEnvironment(environment, changed: changedEnvironment)
            .poppingAttributes(for: self.target)

        if !singleAttributes.isEmpty {
            let attributesToApply = singleAttributes + accumulatingAttributes.map { $0.1 }

            attributesLogger.trace("     Attributes to apply on \(Value.displayName): \(attributesToApply.count)")
            attributesToApply.forEach { attribute in
                attributesLogger.trace("         - \(attribute.debugDescription)")
            }
        }
        attributesLogger.trace("Remaining attributes for \(Value.displayName)'s edges: \(edgesContext.attributes.count)")

        // Apply attributes
        if !singleAttributes.isEmpty || !accumulatingAttributes.isEmpty {
            guard let target = self.target else {
                fatalError("Invalid 'ElementNode' state: expected a target node of type \(Value.Target.self) to be set to apply attributes on")
            }

            for attribute in singleAttributes {
                attributesLogger.trace("Applying attribute \(attribute) on \(Value.displayName)")
                attribute.anySet(on: target, identifiedBy: ObjectIdentifier(self))
            }

            for (key, attribute) in accumulatingAttributes {
                attributesLogger.trace("Applying attribute \(attribute) on \(Value.displayName)")
                attribute.anySet(on: target, identifiedBy: key)
            }
        }

        // Apply environment attributes
        // Give edges context here since it contains the correct environment values and diff (`context` is our parent's context)
        // TODO: is this necessary? it shouldn't matter
        self.setEnvironmentAttributes(initial: initial, using: edgesContext)

        // Make the element and make edges
        let output = element.map { self.make(element: $0) }

        // Override target position if the element is substantial since our edges
        // must start at 0 (the parent being ourself)

        // Update edges
        let edgesResult = self.updateEdges(
            from: output,
            at: (self.substantial ? 0 : targetPosition),
            using: edgesContext
        )

        // Update state
        targetLogger.trace("Edges result of \(Value.self): \(edgesResult)")
        self.targetCount = edgesResult.targetCount
        self.attributes = attributes
        self.storeContext(context.clearingEnvironment())
        self.storeTargetPosition(targetPosition)

        // Override target count if the element is substantial since it has one target: itself
        if self.substantial {
            self.targetCount = 1
        }

        // Make result
        let result = UpdateResult(
            targetPosition: targetPosition,
            targetCount: self.targetCount
        )
        targetLogger.trace("Update result of \(Value.self): \(result)")

        // Handle initial update
        if initial {
            self.target?.attributesDidSet()
        }

        return result
    }

    func compareAndUpdateAny(with element: (any Element)?, targetPosition: Int, using context: Context) -> UpdateResult {
        let typedElement: Value?
        if let element {
            guard let element = element as? Value else {
                fatalError("Cannot update \(Value.self) with type-erased element: expected \(Value.self), got \(type(of: element))")
            }

            typedElement = element
        } else {
            typedElement = nil
        }

        return self.compareAndUpdate(with: typedElement, targetPosition: targetPosition, using: context)
    }

    /// Sets environment attributes on the element node.
    func setEnvironmentAttributes(initial: Bool, using context: ElementNodeContext) {
        guard self.substantial else {
            return
        }

        guard let target = self.target else {
            fatalError("Invalid 'ElementNode' state: expected a target node of type \(Value.Target.self) to be set to apply environment on")
        }

        environmentLogger.trace("Setting environment attributes on \(Value.Target.self) (\(target)), initial: \(initial)")

        for changedEnvironment in context.changedEnvironment where changedEnvironment.value || initial {
            let value = context.environment[keyPath: changedEnvironment.key]

            guard let key = context.environment.lastReadEnvironmentKey() else {
                fatalError("Could not get last accessed environment key")
            }

            guard let key = key as? any AttributeEnvironmentKey.Type else {
                // Not an attribute, skipping
                return
            }

            environmentLogger.trace("Setting environment attribute \(key) on \(Value.Target.self) to \(value)")
            key.set(value, on: target)
        }
    }
}

extension ElementNode {
    /// Is this node substantial, aka. does it have a target node?
    var substantial: Bool {
        return Value.Target.self != Never.self
    }

    /// Attaches the target of this node to its parent target node. The target parent
    /// is not always the element parent (it can skip elements).
    func insertTargetInParent(position: Int) {
        func inner(attaching target: TargetNode, at position: Int, to parentNode: any ElementNode) {
            if let parentTarget = parentNode.target {
                parentTarget.insertChild(target, at: position)
                targetLogger.trace("Attaching \(Value.self) to parent \(parentTarget.displayName) at position \(position)")
            } else if let parent = parentNode.parent {
                inner(attaching: target, at: position, to: parent)
            } else {
                targetLogger.trace("Did not find parent to attach \(Value.self) at position \(position)")
            }
        }

        guard let target = self.target else { return }
        guard let parent = self.parent else { return }

        inner(attaching: target, at: position, to: parent)
    }

    var parentTarget: TargetNode? {
        if let parent = self.parent {
            if let target = parent.target {
                return target
            } else {
                return parent.parentTarget
            }
        }

        return nil
    }

    func removeTargetFromParent(targetPosition: Int?) {
        // Step 1: find the parent target node by traversing upwards
        guard let parentTarget = self.parentTarget else { return }
        let targetPosition = targetPosition ?? 0

        // Step 2: traverse the tree downwards and remove every found target node
        // as every deletion offsets the position of the next node by 1, we can remove all nodes
        // in the same position as the one we're removing
        func inner(node: any ElementNode) {
            if node.target != nil {
                let position = targetPosition
                targetLogger.trace("Removing node at position \(position) from \(parentTarget.displayName)")
                parentTarget.removeChild(at: position)
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
