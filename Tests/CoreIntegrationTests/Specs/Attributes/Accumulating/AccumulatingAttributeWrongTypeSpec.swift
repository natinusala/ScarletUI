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

class AccumulatingAttributeWrongTypeSpec: ScarletCoreSpec {
    static let describing = "a view with an accumulating attribute applied of on the wrong target type"

    struct Avatar: View {
        let user: String

        var body: some View {
            Image(source: "avatar://\(user)")
        }
    }

    struct Tested: TestView {
        let filter: Filter

        var body: some View {
            Avatar(user: "me")
                .filter(filter)
        }

        static func spec() -> Spec {
            when("the view is created") {
                given {
                    Tested(filter: .sepia)
                }

                then("target is created") { result in
                    expect(result.target).to(equal(
                        ViewTarget("Tested") {
                            ViewTarget("Avatar") {
                                ImageTarget(source: "avatar://me", filters: [.sepia])
                            }
                        }
                    ))
                }
            }

            when("the attribute doesn't change") {
                given {
                    Tested(filter: .sepia)
                    Tested(filter: .sepia)
                }

                then("target is untouched") { result in
                    expect(result.target).to(equal(
                        ViewTarget("Tested") {
                            ViewTarget("Avatar") {
                                ImageTarget(source: "avatar://me", filters: [.sepia])
                            }
                        }
                    ))
                }

                then("the attribute is not set on the target side") { result in
                    expect(result.first(ImageTarget.self).filtersChanged).to(beFalse())
                }
            }

            when("the attribute changes") {
                given {
                    Tested(filter: .sepia)
                    Tested(filter: .blackAndWhite)
                }

                then("target is untouched") { result in
                    expect(result.target).to(equal(
                        ViewTarget("Tested") {
                            ViewTarget("Avatar") {
                                ImageTarget(source: "avatar://me", filters: [.blackAndWhite])
                            }
                        }
                    ))
                }

                then("the attribute is not set on the target side") { result in
                    expect(result.first(ImageTarget.self).filtersChanged).to(beTrue())
                }
            }
        }
    }
}
