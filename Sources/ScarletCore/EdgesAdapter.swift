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

/// The "edges adapter", tied to an element node, is responsible for taking an element output
/// and apply edges insertions, deletions and updates as well as attach and detach implementation nodes.
protocol EdgesAdapter {
    func updateEdges(_ edges: MakeOutput.Edges, of output: MakeOutput, in node: ElementNode, attributes: AttributesStash, transaction: Transaction)
}

/// Creates an edges adapter for the element node to be created by the given output.
func makeEdgesAdapter(for output: MakeOutput) -> any EdgesAdapter {
    switch output.edges {
        case .static: return StaticEdgesAdapter()
        case .dynamic: return DynamicEdgesAdapter()
    }
}
