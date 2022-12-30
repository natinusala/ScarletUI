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

class AccumulatingAttributeMultipleWrongTypeSpec: ScarletCoreSpec {
    static let describing = "a view with multiple accumulating attributes applied of on the wrong implementation type"

    struct Avatar: View {
        let user: String

        var body: some View {
            Image(source: "avatar://\(user)")
        }
    }

    struct Tested: TestView {
        let filter1: Filter
        let filter2: Filter

        var body: some View {
            Avatar(user: "me")
                .filter(filter1)
                .filter(filter2)
        }

        static func spec() -> Spec {
            when("the view is created") {
                given {
                    Tested(filter1: .sepia, filter2: .blackAndWhite)
                }

                then("implementation is created") { result in
                    expect(result.implementation).to(equal(
                        ViewImpl("Tested") {
                            ViewImpl("Avatar") {
                                ImageImpl(source: "avatar://me", filters: [.sepia, .blackAndWhite])
                            }
                        }
                    ))
                }
            }

            when("no attribute change") {
                given {
                    Tested(filter1: .sepia, filter2: .blackAndWhite)
                    Tested(filter1: .sepia, filter2: .blackAndWhite)
                }

                then("implementation is untouched") { result in
                    expect(result.implementation).to(equal(
                        ViewImpl("Tested") {
                            ViewImpl("Avatar") {
                                ImageImpl(source: "avatar://me", filters: [.sepia, .blackAndWhite])
                            }
                        }
                    ))
                }

                then("the attribute is not set on the implementation side") { result in
                    expect(result.first(ImageImpl.self).filtersChanged).to(beFalse())
                }
            }

            when("the first attribute change") {
                given {
                    Tested(filter1: .sepia, filter2: .blackAndWhite)
                    Tested(filter1: .stereoscopic, filter2: .blackAndWhite)
                }

                then("implementation is updated") { result in
                    expect(result.implementation).to(equal(
                        ViewImpl("Tested") {
                            ViewImpl("Avatar") {
                                ImageImpl(source: "avatar://me", filters: [.stereoscopic, .blackAndWhite])
                            }
                        }
                    ))
                }

                then("the attribute is set on the implementation side") { result in
                    expect(result.first(ImageImpl.self).filtersChanged).to(beTrue())
                }
            }

            when("the second attribute change") {
                given {
                    Tested(filter1: .sepia, filter2: .blackAndWhite)
                    Tested(filter1: .sepia, filter2: .stereoscopic)
                }

                then("implementation is updated") { result in
                    expect(result.implementation).to(equal(
                        ViewImpl("Tested") {
                            ViewImpl("Avatar") {
                                ImageImpl(source: "avatar://me", filters: [.sepia, .stereoscopic])
                            }
                        }
                    ))
                }

                then("the attribute is set on the implementation side") { result in
                    expect(result.first(ImageImpl.self).filtersChanged).to(beTrue())
                }
            }

            when("the attributes are swapped") {
                given {
                    Tested(filter1: .sepia, filter2: .blackAndWhite)
                    Tested(filter1: .blackAndWhite, filter2: .sepia)
                }

                then("implementation is updated") { result in
                    expect(result.implementation).to(equal(
                        ViewImpl("Tested") {
                            ViewImpl("Avatar") {
                                ImageImpl(source: "avatar://me", filters: [.blackAndWhite, .sepia])
                            }
                        }
                    ))
                }

                then("the attribute is set on the implementation side") { result in
                    expect(result.first(ImageImpl.self).filtersChanged).to(beTrue())
                }
            }

            when("both attributes change") {
                given {
                    Tested(filter1: .sepia, filter2: .blackAndWhite)
                    Tested(filter1: .stereoscopic, filter2: .sepia)
                }

                then("implementation is updated") { result in
                    expect(result.implementation).to(equal(
                        ViewImpl("Tested") {
                            ViewImpl("Avatar") {
                                ImageImpl(source: "avatar://me", filters: [.stereoscopic, .sepia])
                            }
                        }
                    ))
                }

                then("the attribute is set on the implementation side") { result in
                    expect(result.first(ImageImpl.self).filtersChanged).to(beTrue())
                }
            }
        }
    }
}
