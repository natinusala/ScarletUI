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

/// Common protocol for all "makeable" elements.
public protocol Makeable {
    func make(input: MakeInput) -> MakeOutput
}


/// Context given when making an element.
public struct MakeContext {
    /// Each `ModifiedContent` pushes the context for its VMCs to this stack. The context is then
    /// picked up by the VMC nodes to make their edge (the "content").
    let vmcContextStack: [ViewModifierContentContext]

    /// Returns an initial empty context.
    public static func root() -> Self {
        return Self(
            vmcContextStack: []
        )
    }

    func pushingVMCContext(context: ViewModifierContentContext) -> Self {
        return Self(
            vmcContextStack: self.vmcContextStack + [context]
        )
    }

    func poppingVMCContext() -> (ViewModifierContentContext, Self) {
        guard let vmcContext = self.vmcContextStack.last else {
            fatalError("Cannot pop `ViewModifierContentContext` stack: the stack is empty")
        }

        return (
            vmcContext, Self(
                vmcContextStack: self.vmcContextStack.dropLast()
            )
        )
    }
}

/// Input for the `make()` function.
public struct MakeInput {
    /// Any previously stored value, if any.
    /// `nil` means that this is the first time this element is
    /// created and there is no storage for it yet.
    public let storage: StorageNode?

    /// Should state be preserved on the element?
    /// If set to `false`, the element state will be overwrote by
    /// what's currently in state storage.
    let preserveState: Bool

    /// Implementation position determined by the parent.
    /// See ``MakeOutput.implementationPosition``.
    /// The parent should always give 0 if it's substantial to reset the position of its children
    /// relative to itself (as it becomes the new root).
    public let implementationPosition: Int

    /// Current context.
    public let context: MakeContext

    public init(
        storage: StorageNode?,
        implementationPosition: Int,
        context: MakeContext,
        preserveState: Bool = false
    ) {
        self.storage = storage
        self.implementationPosition = implementationPosition
        self.context = context
        self.preserveState = preserveState
    }
}

/// An operation to make on a list of dynamic elements.
public enum DynamicOperation {
    /// Insert an element at the given index.
    case insert(id: AnyHashable, at: Int)

    /// Remove element at given index.
    case remove(id: AnyHashable, at: Int)
}

/// Output of the `make()` function.
public struct MakeOutput {
    public enum StaticEdge {
        case some(_ output: MakeOutput)
        case none(_ implementationPosition: Int)

        var implementationPosition: Int {
            switch self {
                case .some(let output):
                    return output.implementationPosition
                case .none(let implementationPosition):
                    return implementationPosition
            }
        }

        var implementationCount: Int {
            switch self {
                case .some(let output):
                    return output.implementationCount
                case .none:
                    return 0
            }
        }
    }

    public enum Edges {
        /// Static edges. Must always have the same count.
        /// Edges can be `nil` if the node children did not change, but
        /// `count` must always be specified.
        case `static`(_: [StaticEdge]?, count: Int)

        /// Operations to perform on the edges in case they are dynamic.
        /// Operations are applied in order, which is important to keep in mind
        /// to avoid trashing the list after insertions, removals and movements.
        case `dynamic`(operations: [DynamicOperation], viewContent: DynamicViewContent?)
    }

    /// The node kind.
    let nodeKind: ElementKind

    /// The node type.
    let nodeType: ElementEdgesQueryable.Type

    /// The resulting node itself.
    /// Can be `nil` if there is nothing to store for that node
    /// or the node did not change.
    let node: ElementOutput?

    /// Position of the node inside its parent implementation node.
    ///
    /// If the node does not have an implementation node, the position must represent the
    /// baseline for the position of all of its children.
    ///
    /// If the node didn't change and the count is the same, return the same position as given in input.
    ///
    /// General flow is:
    /// 1. parent node gives the implementation position in the child input
    /// 2. child knows its position, makes itself recursively starting from there
    /// 3. parent gets the child output back, containing the implementation count
    /// 4. parent increments the next child position by the returned count, then makes the next child following the same principle
    public let implementationPosition: Int

    /// Number of implementation nodes in this node and all of its children.
    /// Will offset the next childrens' position by this amount.
    public let implementationCount: Int

    /// The resulting edges.
    let edges: Edges

    /// Proxy to make and update the element's implementation or attributes.
    /// Can be `nil` if there is no node of if the node did not change.
    let accessor: Accessor?

    /// Context used to make this element. Must give the input
    /// context without mutating it.
    public let context: MakeContext

    public init(
        from input: MakeInput,
        nodeKind: ElementKind,
        nodeType: ElementEdgesQueryable.Type,
        node: ElementOutput?,
        implementationPosition: Int,
        implementationCount: Int,
        edges: Edges,
        accessor: Accessor?
    ) {
        self.nodeKind = nodeKind
        self.nodeType = nodeType
        self.node = node
        self.implementationPosition = implementationPosition
        self.implementationCount = implementationCount
        self.edges = edges
        self.accessor = accessor
        self.context = input.context
    }
}
