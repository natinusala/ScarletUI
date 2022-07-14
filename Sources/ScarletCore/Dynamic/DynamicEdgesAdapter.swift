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

/// Standard dynamic edges adapter that consumes all views and adds them as
/// edges, without any recycling mechanism.
struct DynamicEdgesAdapter: EdgesAdapter {
    func updateEdges(_ edges: MakeOutput.Edges, of output: MakeOutput, in node: ElementNode, attributes: AttributesStash) {
       guard case .dynamic(let operations, let viewContent) = edges else {
           fatalError("Called` updateEdges(for:)` on `DynamicEdgesAdapter` with non-dynamic edges")
       }

        guard let viewContent = viewContent else {
            // No view content provided: assume there is nothing to do
            return
        }

        // Dynamic update: apply every operation in order
        for operation in operations {
            // TODO: detect moves and swaps as well

            switch operation {
                case .insert(let id, let position):
                    self.insertEdge(at: position, identifiedBy: id, in: node, using: viewContent, attributes: attributes)
                case .remove(let id, let position):
                    self.removeEdge(at: position, identifiedBy: id, in: node)
            }
        }

        // Update all edges
        for (position, edge) in node.edges.enumerated() {
            guard case .dynamic(let edge) = edge else {
                fatalError("Tried to dynamically update a static node")
            }

            if let previousNode = edge.node {
                // If the node already exists, update it
                let input = MakeInput(storage: node.storage)
                let output = viewContent.make(at: position, identifiedBy: edge.id, input: input)

                previousNode.update(with: output, attributes: attributes)
            } else {
                // Otherwise, create it
                let input = MakeInput(storage: nil)
                let output = viewContent.make(at: position, identifiedBy: edge.id, input: input)

                // Create storage
                let (storageEdges, elementNodeEdges) = node.prepareEdgesForEdge(output)
                let edgeStorage = StorageNode(
                    elementType: output.nodeType,
                    value: output.node?.storage,
                    edges: storageEdges
                )
                node.storage.edges.dynamicSet(edge: edgeStorage, for: edge.id)

                // Create and insert the edge node
                let edgeNode = ElementNode(
                    parent: node,
                    position: position,
                    kind: output.nodeKind,
                    type: output.nodeType,
                    storage: edgeStorage,
                    edges: elementNodeEdges,
                    implementation: output.accessor?.makeImplementation(),
                    implementationState: .creating,
                    edgesAdapter: makeEdgesAdapter(for: output)
                )

                edge.node = edgeNode
                edge.node?.update(with: output, attributes: attributes)
                edge.node?.attachImplementationToParent()
            }
        }
    }

     /// Removes edge at given position. Dynamic version.
    private func removeEdge(at position: Int, identifiedBy id: AnyHashable, in node: ElementNode) {
        // Detach implementation nodes
        node.edges[position].node?.detachImplementationFromParent()

        // Remove edge and discard storage
        node.edges.remove(at: position)
        node.storage.edges.dynamicSet(edge: nil, for: id)
    }


    /// Inserts a new edge at the given index. Dynamic variant.
    private func insertEdge(at idx: Int, identifiedBy id: AnyHashable, in node: ElementNode, using viewContent: DynamicViewContent, attributes: AttributesStash) {
        guard node.storage.edges.dynamicAt(id: id) == nil else {
            fatalError("Tried to insert an edge on a non-empty storage node - are the dynamic views identifiers truly unique?")
        }

        // Insert a stale edge to have it be created later
        let dynamicEdge = DynamicEdge(id: id)
        node.edges.insert(.dynamic(dynamicEdge), at: idx)

        // After all dynamic edges are inserted, an update pass is made to all edges
        // including this one, which will make and insert it "for real"
    }
}
