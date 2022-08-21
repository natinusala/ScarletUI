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

import Nimble

@testable import ScarletCore

class ForEachSpecSpec: ScarletSpec {
    static let describing = "a ForEach view"

    // Necessary to assert body calls (`EmptyView` and `ModifiedContent` don't have a body)
    struct NestedView: View {
        let id: String // to force body calls when id changes, allows using `result.bodyCalls(of: NestedView.self)`

        var body: some View {
            EmptyView()
        }
    }

    struct Tested: TestView {
        let views: [Int]

        var idPrefix: String = ""

        var body: some View {
            ForEach(views, id: \.self) { id in
                NestedView(id: "\(self.idPrefix)\(id)")
                    .id("\(self.idPrefix)\(id)")
            }
        }

        static func spec() -> Specs {
            when("the view is created") {
                given {
                    Tested(views: [0, 1, 2, 3, 4])
                }

                then("implementation is created") { result in
                    expect(result.implementation).to(equal(
                        ViewImpl("Tested") {
                            ViewImpl("NestedView", id: "0").anyChildren()
                            ViewImpl("NestedView", id: "1").anyChildren()
                            ViewImpl("NestedView", id: "2").anyChildren()
                            ViewImpl("NestedView", id: "3").anyChildren()
                            ViewImpl("NestedView", id: "4").anyChildren()
                        }
                    ))
                }
            }

            when("the view input does not change") {
                given {
                    Tested(views: [0, 1, 2, 3, 4])
                    Tested(views: [0, 1, 2, 3, 4])
                }

                then("no element views body is called") { result in
                    expect(result.bodyCalls(of: NestedView.self)).to(equal(0))
                }

                then("implementation is untouched") { result in
                    expect(result.implementation).to(equal(
                        ViewImpl("Tested") {
                            ViewImpl("NestedView", id: "0").anyChildren()
                            ViewImpl("NestedView", id: "1").anyChildren()
                            ViewImpl("NestedView", id: "2").anyChildren()
                            ViewImpl("NestedView", id: "3").anyChildren()
                            ViewImpl("NestedView", id: "4").anyChildren()
                        }
                    ))
                }
            }

            when("views are inserted") {
                given {
                     Tested(views: [0, 1, 2, 3, 4])
                     Tested(views: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9])
                }

                then("inserted views' body is called") { result in
                    expect(result.bodyCalls(of: NestedView.self)).to(equal(5))
                }

                then("implementations are inserted") { result in
                    expect(result.implementation).to(equal(
                        ViewImpl("Tested") {
                            ViewImpl("NestedView", id: "0").anyChildren()
                            ViewImpl("NestedView", id: "1").anyChildren()
                            ViewImpl("NestedView", id: "2").anyChildren()
                            ViewImpl("NestedView", id: "3").anyChildren()
                            ViewImpl("NestedView", id: "4").anyChildren()
                            ViewImpl("NestedView", id: "5").anyChildren()
                            ViewImpl("NestedView", id: "6").anyChildren()
                            ViewImpl("NestedView", id: "7").anyChildren()
                            ViewImpl("NestedView", id: "8").anyChildren()
                            ViewImpl("NestedView", id: "9").anyChildren()
                        }
                    ))
                }
            }

            when("views are removed") {
                given { 
                    Tested(views: [0, 1, 2, 3, 4])
                    Tested(views: [])
                }

                then("no element views body is called") { result in
                    expect(result.bodyCalls(of: NestedView.self)).to(equal(0))
                }

                then("implementations are removed") { result in
                    expect(result.implementation).to(equal(
                        ViewImpl("Tested")
                    ))
                }
            }

            when("views are reordered") {
                given {
                    Tested(views: [0, 1, 2, 3, 4])
                    Tested(views: [0, 3, 2, 4, 1])
                }

                // then("no element views body is called") { result in // TODO: restore that test once moves are implemented
                //     expect(result.bodyCalls(of: NestedView.self)).to(equal(0))
                // }

                then("implementations are reordered") { result in
                    expect(result.implementation).to(equal(
                        ViewImpl("Tested") {
                            ViewImpl("NestedView", id: "0").anyChildren()
                            ViewImpl("NestedView", id: "3").anyChildren()
                            ViewImpl("NestedView", id: "2").anyChildren()
                            ViewImpl("NestedView", id: "4").anyChildren()
                            ViewImpl("NestedView", id: "1").anyChildren()
                        }
                    ))
                }
            }

            when("generated views change without reordering") {
                given {
                    Tested(views: [0, 1, 2, 3, 4])
                    Tested(views: [0, 1, 2, 3, 4], idPrefix: "somePrefix")
                }

                then("body is called on all views") { result in
                    expect(result.bodyCalls(of: NestedView.self)).to(equal(5))
                }

                then("implementations are updated") { result in
                    expect(result.implementation).to(equal(
                        ViewImpl("Tested") {
                            ViewImpl("NestedView", id: "somePrefix0").anyChildren()
                            ViewImpl("NestedView", id: "somePrefix1").anyChildren()
                            ViewImpl("NestedView", id: "somePrefix2").anyChildren()
                            ViewImpl("NestedView", id: "somePrefix3").anyChildren()
                            ViewImpl("NestedView", id: "somePrefix4").anyChildren()
                        }
                    ))
                }
            }

            when("generated views change with reordering") {
                given {
                    Tested(views: [0, 1, 2, 3, 4]) 
                    Tested(views: [0, 4, 3, 2, 1], idPrefix: "somePrefix")
                }

                then("body is called on all views") { result in
                    expect(result.bodyCalls(of: NestedView.self)).to(equal(5))
                }

                then("implementations are updated") { result in
                    expect(result.implementation).to(equal(
                        ViewImpl("Tested") {
                            ViewImpl("NestedView", id: "somePrefix0").anyChildren()
                            ViewImpl("NestedView", id: "somePrefix4").anyChildren()
                            ViewImpl("NestedView", id: "somePrefix3").anyChildren()
                            ViewImpl("NestedView", id: "somePrefix2").anyChildren()
                            ViewImpl("NestedView", id: "somePrefix1").anyChildren()
                        }
                    ))
                }
            }
        }
    }
}
