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

import Quick
import Nimble

import ScarletCoreFixtures

@testable import ScarletCore

class DynamicEdgesAdapterSpecs: QuickSpec {
    override func spec() {
        describe("a dynamic view update operation") {
            context("when no view content is provided") {
                it("does nothing") {
                    let adapter = DynamicEdgesAdapter()
                    let output = MakeOutput(
                        nodeKind: .view,
                        nodeType: EmptyView.self,
                        node: nil,
                        edges: .dynamic(operations: [], viewContent: nil),
                        accessor: nil
                    )
                    let node = ElementNode.dynamicEmpty(adapter: adapter)

                    expect(node.edges.count).to(equal(0))

                    adapter.updateEdges(output.edges, of: output, in: node, attributes: [:])

                    expect(node.edges.count).to(equal(0))
                }
            }

            context("when there are no operations to apply") {
                it("updates everything") {
                    
                }
            }

            context("when an insertion is made") {
                it("inserts the node") {

                }

                it("updates everything") {

                }
            }

            context("when a removal is made") {
                it("removes the node") {

                }

                it("updates everything") {

                }
            }

            context("when mixed operations are made") {
                it("applies operations") {

                }

                it("updates everything") {

                }
            }
        }

    }
}
