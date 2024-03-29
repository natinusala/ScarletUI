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

class AccumulatingAttributeAccumulationSpec: ScarletCoreSpec {
    static let describing = "a view with multiple accumulating attributes accumulated on different levels"

    struct FilteredImage: View {
        let filter: Filter

        var body: some View {
            Image(source: "avatar")
                .filter(filter)
        }
    }

    struct Tested: TestView {
        let topFilter: Filter
        let bottomFilter: Filter

        var body: some View {
            FilteredImage(filter: bottomFilter)
                .filter(topFilter)
        }

        static func spec() -> Spec {
            when("the view is created") {
                given {
                    Tested(topFilter: .blackAndWhite, bottomFilter: .sepia)
                }

                then("target is created") { result in
                    expect(result.target).to(equal(
                        ViewTarget("Tested") {
                            ViewTarget("FilteredImage") {
                                ImageTarget(source: "avatar", filters: [.sepia, .blackAndWhite])
                            }
                        }
                    ))
                }
            }

            when("nothing changes") {
                given {
                    Tested(topFilter: .blackAndWhite, bottomFilter: .sepia)
                    Tested(topFilter: .blackAndWhite, bottomFilter: .sepia)
                }

                then("target is untouched") { result in
                    expect(result.target).to(equal(
                        ViewTarget("Tested") {
                            ViewTarget("FilteredImage") {
                                ImageTarget(source: "avatar", filters: [.sepia, .blackAndWhite])
                            }
                        }
                    ))
                }

                then("attributes are not set on the target") { result in
                    expect(result.first(ImageTarget.self).filtersChanged).to(beFalse())
                }

                then("view body is not called") { result in
                    expect(result.bodyCalled(of: FilteredImage.self)).to(beFalse())
                }
            }

            when("the top-level attribute changes") {
                given {
                    Tested(topFilter: .blackAndWhite, bottomFilter: .sepia)
                    Tested(topFilter: .stereoscopic, bottomFilter: .sepia)
                }

                then("target is updated") { result in
                    expect(result.target).to(equal(
                        ViewTarget("Tested") {
                            ViewTarget("FilteredImage") {
                                ImageTarget(source: "avatar", filters: [.stereoscopic, .sepia])
                            }
                        }
                    ))
                }

                then("attribute is set on the target") { result in
                    expect(result.first(ImageTarget.self).filtersChanged).to(beTrue())
                }

                then("view body is not called") { result in
                    expect(result.bodyCalled(of: FilteredImage.self)).to(beFalse())
                }
            }

            when("the bottom-level attribute changes") {
                given {
                    Tested(topFilter: .blackAndWhite, bottomFilter: .sepia)
                    Tested(topFilter: .blackAndWhite, bottomFilter: .stereoscopic)
                }

                then("target is updated") { result in
                    expect(result.target).to(equal(
                        ViewTarget("Tested") {
                            ViewTarget("FilteredImage") {
                                ImageTarget(source: "avatar", filters: [.blackAndWhite, .stereoscopic])
                            }
                        }
                    ))
                }

                then("attribute is set on the target") { result in
                    expect(result.first(ImageTarget.self).filtersChanged).to(beTrue())
                }

                then("view body is called") { result in
                    // Because `bottomFilter` changed
                    expect(result.bodyCalled(of: FilteredImage.self)).to(beTrue())
                }
            }
        }
    }
}
