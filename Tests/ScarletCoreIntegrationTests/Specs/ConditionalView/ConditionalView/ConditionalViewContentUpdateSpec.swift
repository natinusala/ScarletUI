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

class ConditionalViewContentUpdateSpec: ScarletSpec {
    static let describing = "a view with a conditional which content gets updated"

    struct Tested: TestView {
        var hasImageRow: Bool
        var imageUrl: String

        var body: some View {
            Column {
                if hasImageRow {
                    Row {
                        Image(source: imageUrl)
                    }
                } else {
                    Image(source: imageUrl)
                }
                Row {
                    Text("Text 1")
                    Text("Text 2")
                    Text("Text 3")
                }
            }
        }

        static func spec() -> Spec {
            when("view is created with first") {
                given {
                    Tested(hasImageRow: true, imageUrl: "http://website.com/picture.png")
                }

                then("implementation is created") { result in
                    expect(result.implementation).to(equal(
                        ViewImpl("Tested") {
                            ViewImpl("Column") {
                                ViewImpl("Row") {
                                    ImageImpl(source: "http://website.com/picture.png")
                                }

                                ViewImpl("Row") {
                                    TextImpl(text: "Text 1")
                                    TextImpl(text: "Text 2")
                                    TextImpl(text: "Text 3")
                                }
                            }
                        }
                    ))
                }
            }

            when("view is created with second") {
                given {
                    Tested(hasImageRow: false, imageUrl: "http://website.com/picture.png")
                }

                then("implementation is created") { result in
                    expect(result.implementation).to(equal(
                        ViewImpl("Tested") {
                            ViewImpl("Column") {
                                ImageImpl(source: "http://website.com/picture.png")

                                ViewImpl("Row") {
                                    TextImpl(text: "Text 1")
                                    TextImpl(text: "Text 2")
                                    TextImpl(text: "Text 3")
                                }
                            }
                        }
                    ))
                }
            }

            when("the first content is updated") {
                given {
                    Tested(hasImageRow: true, imageUrl: "http://website.com/picture.png")
                    Tested(hasImageRow: true, imageUrl: "http://website.com/picture2.png")
                }

                then("implementation is created") { result in
                    expect(result.implementation).to(equal(
                        ViewImpl("Tested") {
                            ViewImpl("Column") {
                                ViewImpl("Row") {
                                    ImageImpl(source: "http://website.com/picture2.png")
                                }

                                ViewImpl("Row") {
                                    TextImpl(text: "Text 1")
                                    TextImpl(text: "Text 2")
                                    TextImpl(text: "Text 3")
                                }
                            }
                        }
                    ))
                }
            }

            when("the second content is updated") {
                given {
                    Tested(hasImageRow: false, imageUrl: "http://website.com/picture.png")
                    Tested(hasImageRow: false, imageUrl: "http://website.com/picture2.png")
                }

                then("implementation is created") { result in
                    expect(result.implementation).to(equal(
                        ViewImpl("Tested") {
                            ViewImpl("Column") {
                                ImageImpl(source: "http://website.com/picture2.png")

                                ViewImpl("Row") {
                                    TextImpl(text: "Text 1")
                                    TextImpl(text: "Text 2")
                                    TextImpl(text: "Text 3")
                                }
                            }
                        }
                    ))
                }
            }
        }
    }
}
