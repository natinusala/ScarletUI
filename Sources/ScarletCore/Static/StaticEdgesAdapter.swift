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

/// Edges adapter for static views that takes the view output and flips edges on and off.
/// Each view type has a static edges layout, edges are simply flipped on and off in their "slot"
/// but they are never added or removed.
struct StaticEdgesAdapter: EdgesAdapter {
    func updateEdges(_ edges: MakeOutput.Edges, of output: MakeOutput, in node: ElementNode, attributes: AttributesStash) {
        guard case .static(let staticEdges, _) = edges else {
            fatalError("Called` updateEdges(for:)` on `StaticEdgesAdapter` with non-static edges")
        }

        // Static update: update every edge one by one
        guard let staticEdges = staticEdges else { return }

        assert(
            staticEdges.count == node.edges.count,
            "`\(output.nodeType).make()` returned the wrong number of static edges (expected \(node.edges.count), got \(staticEdges.count))"
        )

        for idx in 0 ..< node.edges.count {
            switch (node.edges[idx].node, staticEdges[idx]) {
                case (.none, .none):
                    // Nothing to do
                    break
                case (.none, .some(let newEdge)):
                    // Create a new edge
                    self.insertEdge(newEdge, at: idx, in: node, attributes: attributes)
                case (.some, .none(let implementationPosition)):
                    // Remove the old edge
                    self.removeEdge(at: idx, in: node, implementationPosition: implementationPosition)
                case (.some, .some(let newEdge)):
                    // Update the edge
                    self.updateEdge(at: idx, with: newEdge, in: node, attributes: attributes)
            }
        }
    }

     /// Inserts a new edge at the given index. Static variant.
    private func insertEdge(_ edge: MakeOutput, at idx: Int, in node: ElementNode, attributes: AttributesStash) {
        // Prepare the edge storage and node depending on its type
        let (storageEdges, elementNodeEdges) = node.prepareEdgesForEdge(edge)

        // Create the storage node
        let edgeStorage = StorageNode(
            elementType: edge.nodeType,
            value: edge.node?.storage,
            edges: storageEdges
        )
        node.storage.edges.staticSet(edge: edgeStorage, at: idx)

        // Create and insert the edge node
        let edgeNode = ElementNode(
            parent: node,
            kind: edge.nodeKind,
            type: edge.nodeType,
            storage: edgeStorage,
            edges: elementNodeEdges,
            implementation: edge.accessor?.makeImplementation(),
            implementationState: .creating,
            edgesAdapter: makeEdgesAdapter(for: edge),
            context: edge.context
        )

        node.edges[idx] = .static(edgeNode)
        node.edges[idx].node?.update(with: edge, attributes: attributes)
        node.edges[idx].node?.attachImplementationToParent()
    }

    /// Updates edge at given position with a new edge.
    private func updateEdge(at idx: Int, with newEdge: MakeOutput, in node: ElementNode, attributes: AttributesStash) {
        guard let edge = node.edges[idx].node else {
            fatalError("Cannot update an edge that doesn't exist")
        }

        // If the type is the same, simply update the edge
        // otherwise remove the old one and put the new one in place
        if edge.type == newEdge.nodeType {
            edge.update(with: newEdge, attributes: attributes)
        } else {
            self.removeEdge(at: idx, in: node, implementationPosition: newEdge.implementationPosition)
            self.insertEdge(newEdge, at: idx, in: node, attributes: attributes)
        }
    }

    /// Removes edge at given position. Static version.
    private func removeEdge(at idx: Int, in node: ElementNode, implementationPosition: Int?) {
        // Detach implementation nodes
        node.edges[idx].node?.detachImplementationFromParent(implementationPosition: implementationPosition)

        // Remove edge and discard storage
        node.edges[idx] = .static(nil)
        node.storage.edges.staticSet(edge: nil, at: idx)
    }
}
