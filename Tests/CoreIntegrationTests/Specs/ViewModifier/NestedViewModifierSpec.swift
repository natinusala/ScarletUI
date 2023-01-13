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

class NestedViewModifierSpec: ScarletCoreSpec {
    static let describing = "a view with nested modified views"

    struct Modified: View {
        let color: String
        let imageSrc: String
        let imageModifierText: String

        var body: some View {
            Text("Color: \(color)")

            Image(source: imageSrc)
                .someModifier(text: imageModifierText)
        }
    }

    struct Tested: TestView {
        let color: String
        let imageSrc: String
        let modifiedModifierText: String
        let imageModifierText: String

        var body: some View {
            Modified(
                color: color,
                imageSrc: imageSrc,
                imageModifierText: imageModifierText
            )
                .someModifier(text: modifiedModifierText)
        }

        static func spec() -> Spec {
            when("the view is created") {
                given {
                    Tested(
                        color: "yellow",
                        imageSrc: "modified-image.png",
                        modifiedModifierText: "modified modifier",
                        imageModifierText: "modified image"
                    )
                }

                then("target is created") { result in
                    expect(result.target).to(equal(
                        ViewTarget("Tested") {
                            ViewTarget("Row") {
                                TextTarget(text: "modified modifier")

                                ViewTarget("Modified") {
                                    TextTarget(text: "Color: yellow")

                                    ViewTarget("Row") {
                                        TextTarget(text: "modified image")

                                        ImageTarget(source: "modified-image.png")
                                    }
                                }
                            }
                        }
                    ))
                }
            }

            when("nothing changes") {
                given {
                    Tested(
                        color: "yellow",
                        imageSrc: "modified-image.png",
                        modifiedModifierText: "modified modifier",
                        imageModifierText: "modified image"
                    )

                    Tested(
                        color: "yellow",
                        imageSrc: "modified-image.png",
                        modifiedModifierText: "modified modifier",
                        imageModifierText: "modified image"
                    )
                }

                then("target is unchanged") { result in
                    expect(result.target).to(equal(
                        ViewTarget("Tested") {
                            ViewTarget("Row") {
                                TextTarget(text: "modified modifier")

                                ViewTarget("Modified") {
                                    TextTarget(text: "Color: yellow")

                                    ViewTarget("Row") {
                                        TextTarget(text: "modified image")

                                        ImageTarget(source: "modified-image.png")
                                    }
                                }
                            }
                        }
                    ))
                }
            }

            when("the first modified view is updated") {
                given {
                    Tested(
                        color: "yellow",
                        imageSrc: "modified-image.png",
                        modifiedModifierText: "modified modifier",
                        imageModifierText: "modified image"
                    )

                    Tested(
                        color: "blue",
                        imageSrc: "modified-image.png",
                        modifiedModifierText: "modified modifier",
                        imageModifierText: "modified image"
                    )
                }

                then("target is updated") { result in
                    expect(result.target).to(equal(
                        ViewTarget("Tested") {
                            ViewTarget("Row") {
                                TextTarget(text: "modified modifier")

                                ViewTarget("Modified") {
                                    TextTarget(text: "Color: blue")

                                    ViewTarget("Row") {
                                        TextTarget(text: "modified image")

                                        ImageTarget(source: "modified-image.png")
                                    }
                                }
                            }
                        }
                    ))
                }

                then("tested view body is called") { result in
                    expect(result.bodyCalled(of: Tested.self)).to(beTrue())
                }

                then("modified view body is called") { result in
                    expect(result.bodyCalled(of: Modified.self)).to(beTrue())
                }

                then("modifier body is not called") { result in
                    expect(result.bodyCalled(of: SomeModifier.self)).to(beFalse())
                }
            }

            when("the first modified view and its modifier are updated") {
                given {
                    Tested(
                        color: "yellow",
                        imageSrc: "modified-image.png",
                        modifiedModifierText: "modified modifier",
                        imageModifierText: "modified image"
                    )

                    Tested(
                        color: "blue",
                        imageSrc: "modified-image.png",
                        modifiedModifierText: "some other modified modifier",
                        imageModifierText: "modified image"
                    )
                }

                then("target is updated") { result in
                    expect(result.target).to(equal(
                        ViewTarget("Tested") {
                            ViewTarget("Row") {
                                TextTarget(text: "some other modified modifier")

                                ViewTarget("Modified") {
                                    TextTarget(text: "Color: blue")

                                    ViewTarget("Row") {
                                        TextTarget(text: "modified image")

                                        ImageTarget(source: "modified-image.png")
                                    }
                                }
                            }
                        }
                    ))
                }

                then("tested view body is called") { result in
                    expect(result.bodyCalled(of: Tested.self)).to(beTrue())
                }

                then("modified view body is called") { result in
                    expect(result.bodyCalled(of: Modified.self)).to(beTrue())
                }

                then("modifier body is called") { result in
                    expect(result.bodyCalled(of: SomeModifier.self)).to(beTrue())
                }
            }

            when("the first modifier is updated") {
                given {
                    Tested(
                        color: "blue",
                        imageSrc: "modified-image.png",
                        modifiedModifierText: "modified modifier",
                        imageModifierText: "modified image"
                    )

                    Tested(
                        color: "blue",
                        imageSrc: "modified-image.png",
                        modifiedModifierText: "some other modified modifier",
                        imageModifierText: "modified image"
                    )
                }

                then("target is updated") { result in
                    expect(result.target).to(equal(
                        ViewTarget("Tested") {
                            ViewTarget("Row") {
                                TextTarget(text: "some other modified modifier")

                                ViewTarget("Modified") {
                                    TextTarget(text: "Color: blue")

                                    ViewTarget("Row") {
                                        TextTarget(text: "modified image")

                                        ImageTarget(source: "modified-image.png")
                                    }
                                }
                            }
                        }
                    ))
                }

                then("tested view body is called") { result in
                    expect(result.bodyCalled(of: Tested.self)).to(beTrue())
                }

                then("modified view body is not called") { result in
                    expect(result.bodyCalled(of: Modified.self)).to(beFalse())
                }

                then("modifier body is called") { result in
                    expect(result.bodyCalled(of: SomeModifier.self)).to(beTrue())
                }
            }

            when("the second modified view is updated") {
                given {
                    Tested(
                        color: "blue",
                        imageSrc: "modified-image.png",
                        modifiedModifierText: "modified modifier",
                        imageModifierText: "modified image"
                    )

                    Tested(
                        color: "blue",
                        imageSrc: "another-image.png",
                        modifiedModifierText: "modified modifier",
                        imageModifierText: "modified image"
                    )
                }

                then("target is updated") { result in
                    expect(result.target).to(equal(
                        ViewTarget("Tested") {
                            ViewTarget("Row") {
                                TextTarget(text: "modified modifier")

                                ViewTarget("Modified") {
                                    TextTarget(text: "Color: blue")

                                    ViewTarget("Row") {
                                        TextTarget(text: "modified image")

                                        ImageTarget(source: "another-image.png")
                                    }
                                }
                            }
                        }
                    ))
                }

                then("tested view body is called") { result in
                    expect(result.bodyCalled(of: Tested.self)).to(beTrue())
                }

                then("modified view body is called") { result in
                    expect(result.bodyCalled(of: Modified.self)).to(beTrue())
                }

                then("modifier body is not called") { result in
                    expect(result.bodyCalled(of: SomeModifier.self)).to(beFalse())
                }
            }

            when("the second modified view and its modifier are updated") {
                given {
                    Tested(
                        color: "blue",
                        imageSrc: "modified-image.png",
                        modifiedModifierText: "modified modifier",
                        imageModifierText: "modified image"
                    )

                    Tested(
                        color: "blue",
                        imageSrc: "another-image.png",
                        modifiedModifierText: "modified modifier",
                        imageModifierText: "another modified image"
                    )
                }

                then("target is updated") { result in
                    expect(result.target).to(equal(
                        ViewTarget("Tested") {
                            ViewTarget("Row") {
                                TextTarget(text: "modified modifier")

                                ViewTarget("Modified") {
                                    TextTarget(text: "Color: blue")

                                    ViewTarget("Row") {
                                        TextTarget(text: "another modified image")

                                        ImageTarget(source: "another-image.png")
                                    }
                                }
                            }
                        }
                    ))
                }

                then("tested view body is called") { result in
                    expect(result.bodyCalled(of: Tested.self)).to(beTrue())
                }

                then("modified view body is called") { result in
                    expect(result.bodyCalled(of: Modified.self)).to(beTrue())
                }

                then("modifier body is called") { result in
                    expect(result.bodyCalled(of: SomeModifier.self)).to(beTrue())
                }
            }

            when("the second modifier is updated") {
                given {
                    Tested(
                        color: "blue",
                        imageSrc: "another-image.png",
                        modifiedModifierText: "modified modifier",
                        imageModifierText: "modified image"
                    )

                    Tested(
                        color: "blue",
                        imageSrc: "another-image.png",
                        modifiedModifierText: "modified modifier",
                        imageModifierText: "another modified image"
                    )
                }

                then("target is updated") { result in
                    expect(result.target).to(equal(
                        ViewTarget("Tested") {
                            ViewTarget("Row") {
                                TextTarget(text: "modified modifier")

                                ViewTarget("Modified") {
                                    TextTarget(text: "Color: blue")

                                    ViewTarget("Row") {
                                        TextTarget(text: "another modified image")

                                        ImageTarget(source: "another-image.png")
                                    }
                                }
                            }
                        }
                    ))
                }

                then("tested view body is called") { result in
                    expect(result.bodyCalled(of: Tested.self)).to(beTrue())
                }

                then("modified view body is called") { result in
                    expect(result.bodyCalled(of: Modified.self)).to(beTrue())
                }

                then("modifier body is called") { result in
                    expect(result.bodyCalled(of: SomeModifier.self)).to(beTrue())
                }
            }
        }
    }
}

private struct SomeModifier: ViewModifier {
    let text: String

    func body(content: Content) -> some View {
        Row {
            Text(text)

            content
        }
    }
}

private extension View {
    func someModifier(text: String) -> some View {
        return self.modified(by: SomeModifier(text: text))
    }
}
