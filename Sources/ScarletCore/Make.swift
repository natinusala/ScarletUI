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

    public init(
        storage: StorageNode?,
        implementationPosition: Int,
        preserveState: Bool = false
    ) {
        self.storage = storage
        self.implementationPosition = implementationPosition
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
    public enum Edges {
        /// Static edges. Must always have the same count.
        /// Edges can be `nil` if the node children did not change, but
        /// `count` must always be specified.
        case `static`(_: [MakeOutput?]?, count: Int)

        /// Operations to perform on the edges in case they are dynamic.
        /// Operations are applied in order, which is important to keep in mind
        /// to avoid trashing the list after insertions, removals and movements.
        case `dynamic`(operations: [DynamicOperation], viewContent: DynamicViewContent?)
    }

    /// The node kind.
    let nodeKind: ElementKind

    /// The node type.
    let nodeType: Any.Type

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

    public init(
        nodeKind: ElementKind,
        nodeType: Any.Type,
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
    }

    /// Makes a copy of that output with the edges replaced.
    public func withEdges(_ edges: Edges, implementationCount: Int) -> MakeOutput {
        return MakeOutput(
            nodeKind: self.nodeKind,
            nodeType: self.nodeType,
            node: self.node,
            implementationPosition: self.implementationPosition,
            implementationCount: implementationCount,
            edges: edges,
            accessor: self.accessor
        )
    }
}
