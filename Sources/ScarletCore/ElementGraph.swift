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

import Foundation

import Runtime
import OpenCombine

/// Output of one element in the `make()` function.
public struct ElementOutput {
    /// Any value to store and pass to the next `make()` call.
    let storage: Any?

    /// Attributes for this node.
    /// Will be set to the first encountered
    /// implementation node.
    let attributes: AttributesStash

    public init(storage: Any?, attributes: AttributesStash) {
        self.storage = storage
        self.attributes = attributes
    }
}

/// An edge of a dynamic view.
class DynamicEdge {
    /// The node of the edge. `nil` means it's not been created yet.
    var node: ElementNode?

    /// The associated identifier to this edge.
    let id: AnyHashable

    init(id: AnyHashable) {
        self.id = id
    }
}

/// A node of the element graph.
public class ElementNode {
    enum Edge {
        /// Static edge.
        /// `nil` means the view has been removed from the slot (optional view).
        case `static`(ElementNode?)

        // Dynamic edge.
        case `dynamic`(DynamicEdge)

        var node: ElementNode? {
            switch self {
            case .static(let node):
                return node
            case .dynamic(let edge):
                return edge.node
            }
        }
    }

    /// The parent of this node.
    var parent: ElementNode?

    /// Kind of the element.
    var kind: ElementKind

    /// Type of the element.
    var type: Any.Type

    /// Associated storage node for this element.
    let storage: StorageNode

    /// Position of the implementation node in the parent's implementation node.
    /// See ``MakeOutput.implementationPosition``.
    var implementationPosition: Int = 0

    /// Subscription for the storage node, fired whenever
    /// a state value changes.
    var storageSubscription: AnyCancellable?

    /// The edges adapter for this node.
    let edgesAdapter: any EdgesAdapter

    /// Edges for this element.
    var edges: [Edge]

    /// Implementation of this element.
    /// Public to allow the implementation to run the app node.
    public let implementation: ImplementationNode?

    /// Context used to make this element.
    var context: MakeContext

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

    /// Current state of the implementation node.
    var implementationState: ImplementationNodeState

    /// Is this element substantial, aka. does it exist onscreen?
    var substantial: Bool {
        return implementation != nil
    }

    /// Does this element have a storage node?
    var hasStorage: Bool {
        return storage.value != nil
    }

    /// Returns the number of implementations nodes this element and its edges have.
    /// TODO: cache this value instead of requiring a full traversal each time
    var implementationsCount: Int {
        if self.implementation != nil {
            return 1
        }

        return edges.reduce(0) { $0 + ($1.node?.implementationsCount ?? 0) }
    }

    /// Creates a new node for the given view, making it in the process.
    public init<V: View>(parent: ElementNode?, making view: V, implementationPosition: Int = 0, context: MakeContext) {
        self.parent = parent
        self.kind = .view
        self.type = V.self
        self.storage = StorageNode(for: view)
        self.edges = [Edge](repeating: .static(nil), count: V.staticEdgesCount)
        self.context = context

        let input = MakeInput(storage: self.storage, implementationPosition: implementationPosition, context: context)
        let output = V.make(view: view, input: input)

        self.edgesAdapter = makeEdgesAdapter(for: output)

        self.implementation = output.accessor?.makeImplementation()
        self.implementationState = .creating

        self.subscribeToStateChanges()

        self.update(with: output, attributes: [:])

        self.attachImplementationToParent()
    }

    /// Creates a new node for the given app, making it in the process.
    public init<A: App>(parent: ElementNode?, making app: A, implementationPosition: Int = 0, context: MakeContext) {
        self.parent = parent
        self.kind = .app
        self.type = A.self
        self.storage = StorageNode(for: app)
        self.edges = [Edge](repeating: .static(nil), count: A.staticEdgesCount)
        self.context = context

        let input = MakeInput(storage: self.storage, implementationPosition: implementationPosition, context: context)
        let output = A.make(app: app, input: input)

        self.edgesAdapter = makeEdgesAdapter(for: output)

        self.implementation = output.accessor?.makeImplementation()
        self.implementationState = .creating

        self.subscribeToStateChanges()

        self.update(with: output, attributes: [:])

        self.attachImplementationToParent()
    }

    init(
        parent: ElementNode?,
        kind: ElementKind,
        type: Any.Type,
        storage: StorageNode,
        edges: [Edge],
        implementation: ImplementationNode?,
        implementationState: ImplementationNodeState,
        edgesAdapter: any EdgesAdapter,
        context: MakeContext
    ) {
        self.parent = parent
        self.kind = kind
        self.type = type
        self.storage = storage
        self.edges = edges
        self.implementation = implementation
        self.implementationState = implementationState
        self.edgesAdapter = edgesAdapter
        self.context = context

        self.subscribeToStateChanges()
    }

    private func subscribeToStateChanges() {
        self.storageSubscription = self.storage.statePublisher.sink { element in
            if let makeable = element as? Makeable {
                Logger.debug(debugState, "\(self.type) state value changed, re-evaluating body")

                printState(of: element, at: "state change sink (new element)")

                // Make the element preserving state - the version we get from the publisher
                // already has the most up-to-date values for every property
                let input = MakeInput(storage: self.storage, implementationPosition: self.implementationPosition, context: self.context, preserveState: true)
                let output = makeable.make(input: input)

                self.update(with: output, attributes: [:])
            } else {
                fatalError("Cannot re-evaluate body of \(self.type): does not conform to `Makeable`")
            }
        }
    }

    func attachImplementationToParent() {
        func inner(attaching implementation: ImplementationNode, at position: Int, to parentNode: ElementNode) {
            if let parentImplementation = parentNode.implementation {
                Logger.debug(debugImplementation, "Inserting node \(implementation.displayName) at position \(position) into \(parentImplementation.displayName)")
                parentImplementation.insertChild(implementation, at: position)
            } else if let parent = parentNode.parent {
                inner(attaching: implementation, at: position, to: parent)
            }
        }

        guard let implementation = self.implementation else { return }
        guard let parent = self.parent else { return }
        inner(attaching: implementation, at: self.implementationPosition, to: parent)
    }

    func detachImplementationFromParent(implementationPosition: Int?) {
        // Step 1: find the parent implementation node by traversing upwards
        guard let parentImplementation = self.parentImplementation else { return }
        let implementationPosition = implementationPosition ?? 0

        // Step 2: traverse the tree downwards and remove every found implementation node
        // as every deletion offsets the position of the next node by 1, we can remove all nodes
        // in the same position as the one we're removing
        func inner(node: ElementNode) {
            if node.implementation != nil {
                let position = implementationPosition
                Logger.debug(debugImplementation, "Removing node at position \(position) from \(parentImplementation.displayName)")
                parentImplementation.removeChild(at: position)
            } else {
                for edge in node.edges {
                    if let node = edge.node {
                        inner(node: node)
                    }
                }
            }
        }

        inner(node: self)
    }

    /// Updates the node with the given view.
    func update<V: View>(making view: V, attributes: AttributesStash) {
        assert(
            V.self == self.type,
            "cannot update a graph node with a view of a different type"
        )

        let input = MakeInput(storage: self.storage, implementationPosition: self.implementationPosition, context: self.context)
        let output = V.make(view: view, input: input)
        self.update(with: output, attributes: attributes)
    }

    /// Updates the node with the given app.
    public func update<A: App>(making app: A, attributes: AttributesStash) {
        assert(
            A.self == self.type,
            "cannot update a graph node with an app of a different type"
        )

        let input = MakeInput(storage: self.storage, implementationPosition: self.implementationPosition, context: self.context)
        let output = A.make(app: app, input: input)
        self.update(with: output, attributes: attributes)
    }

    /// Updates the node with the output of the given element.
    /// Can update the node data, its edges recursively or nothing at all.
    func update(with output: MakeOutput, attributes: AttributesStash) {
        assert(
            output.nodeType == self.type,
            "make() returned a node of the wrong type (expected \(self.type), got \(output.nodeType))"
        )

        var attributes = attributes // make mutable

        // Update state
        self.implementationPosition = output.implementationPosition
        self.storage.implementationCount = output.implementationCount
        self.context = output.context
        Logger.debug(debugImplementationVerbose, "Setting \(self.type) implementation position to \(self.implementationPosition)")

        // Node update
        if let node = output.node {
            self.type = output.nodeType
            self.storage.value = node.storage
        }

        // Implementation update
        if let accessor = output.accessor, let implementation = self.implementation {
            accessor.updateImplementation(implementation)
        }

        // Attributes updates
        let newAttributes = output.node?.attributes ?? [:]
        newAttributes.forEach { attributes[$0] = $1 }

        if let implementation = self.implementation {
            attributes = attributes.filter {
                let set = $1.set(on: implementation)
                let propagate = $1.propagate

                // Remove it from the stash if it's been set and if it's not propagated
                return !set || propagate
            }

            // Call `attributesDidSet()` only at first update
            if self.implementationState == .creating {
                implementation.attributesDidSet()
                self.implementationState = .created
            }
        }

        // Edges update
        self.edgesAdapter.updateEdges(
            output.edges,
            of: output,
            in: self,
            attributes: attributes
        )
    }

    /// Creates both storage node edges and element node edges for a given edge to insert.
    func prepareEdgesForEdge(_ edge: MakeOutput) -> (StorageNode.Edges, [Edge]) {
        let storageEdges: StorageNode.Edges
        let elementNodeEdges: [Edge]
        switch edge.edges {
            case .static(_, let count):
                storageEdges = .static([StorageNode?](repeating: nil, count: count))
                elementNodeEdges = [Edge](repeating: .static(nil), count: count)
            case .dynamic:
                storageEdges = .dynamic([:])
                elementNodeEdges = []
        }

        return (storageEdges, elementNodeEdges)
    }

    func printGraph(indent: Int = 0) {
        let indentString = String(repeating: " ", count: indent)
        print("\(indentString)- \(self.type): \(self.kind.displayName) (has storage: \(self.hasStorage))")

        for edge in self.edges {
            if let node = edge.node {
                node.printGraph(indent: indent + 4)
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

public typealias Accessor = ImplementationAccessor & AttributeAccessor

/// Different states of an implementation node.
public enum ImplementationNodeState {
    /// The node is being created and attributes are being set.
    case creating

    /// The node is fully created and all attributes are set.
    case created
}

func printState(of element: @autoclosure () -> Any, at prefix: String) {
    guard debugState else { return }

    let element = element()
    let type = Swift.type(of: element)

    Logger.debug(debugState, "State of \(type) at \(prefix):")

    let elementInfo = try? typeInfo(of: type)
    for property in elementInfo?.properties ?? [] {
        if let stateProperty = try? property.get(from: element) as? StateProperty {
            Logger.debug(debugState, "      - \(property.name): \(stateProperty.anyValue) (initialized: \(stateProperty.location != nil))")
        }
    }
}
