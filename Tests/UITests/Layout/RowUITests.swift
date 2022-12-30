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

import ScarletUITests
import Quick
import Nimble

class RowUITests: QuickSpec {
    struct Tested: View {
        let grow1: Float
        let grow2: Float
        let grow3: Float
        let width: LayoutValue

        @State private var hideRectangle2 = false

        var body: some View {
            Row {
                Rectangle(color: .red)
                    .grow(grow1)
                    .width(width)
                    .tag("rectangle1")

                if !hideRectangle2 {
                    Rectangle(color: .green)
                        .grow(grow2)
                        .width(width)
                        .tag("rectangle2")
                }

                Rectangle(color: .blue)
                    .grow(grow3)
                    .width(width)
                    .tag("rectangle3")
            }.grow()
        }
    }

    override func spec() {
        describe("a row with equally growing rectangles") {
            var app: ScarletUIApplication<Tested>!
            beforeEach {
                app = await ScarletUIApplication(
                    testing: Tested(grow1: 1.0, grow2: 1.0, grow3: 1.0, width: .auto),
                    windowMode: .windowed(width: 600, height: 600)
                )
            }

            context("when creating the row") {
                it("lays out rectangles equally") {
                    let rectangle1 = await app.view(tagged: "rectangle1")
                    let rectangle2 = await app.view(tagged: "rectangle2")
                    let rectangle3 = await app.view(tagged: "rectangle3")

                    expect(rectangle1?.layout).to(equal(Rect(x: 0, y: 0, width: 200, height: 600)))
                    expect(rectangle2?.layout).to(equal(Rect(x: 200, y: 0, width: 200, height: 600)))
                    expect(rectangle3?.layout).to(equal(Rect(x: 400, y: 0, width: 200, height: 600)))
                }
            }

            context("when a rectangle is hidden") {
                beforeEach {
                    await app.setState("hideRectangle2", to: true)
                }

                it("hides the rectangle") {
                    expect(app).to(notHaveView(tagged: "rectangle2"))
                }

                it("updates layout") {
                    let rectangle1 = await app.view(tagged: "rectangle1")
                    let rectangle3 = await app.view(tagged: "rectangle3")

                    expect(rectangle1?.layout).to(equal(Rect(x: 0, y: 0, width: 300, height: 600)))
                    expect(rectangle3?.layout).to(equal(Rect(x: 300, y: 0, width: 300, height: 600)))
                }
            }
        }

        describe("a row with fixed width rectangles") {
            var app: ScarletUIApplication<Tested>!
            beforeEach {
                app = await ScarletUIApplication(
                    testing: Tested(grow1: 0, grow2: 0, grow3: 0, width: 100),
                    windowMode: .windowed(width: 600, height: 600)
                )
            }

            context("when creating the row") {
                it("lays out rectangles with fixed width") {
                    let rectangle1 = await app.view(tagged: "rectangle1")
                    let rectangle2 = await app.view(tagged: "rectangle2")
                    let rectangle3 = await app.view(tagged: "rectangle3")

                    expect(rectangle1?.layout).to(equal(Rect(x: 0, y: 0, width: 100, height: 600)))
                    expect(rectangle2?.layout).to(equal(Rect(x: 100, y: 0, width: 100, height: 600)))
                    expect(rectangle3?.layout).to(equal(Rect(x: 200, y: 0, width: 100, height: 600)))
                }
            }

            context("when a rectangle is hidden") {
                beforeEach {
                    await app.setState("hideRectangle2", to: true)
                }

                it("hides the rectangle") {
                    expect(app).to(notHaveView(tagged: "rectangle2"))
                }

                it("updates layout") {
                    let rectangle1 = await app.view(tagged: "rectangle1")
                    let rectangle3 = await app.view(tagged: "rectangle3")

                    expect(rectangle1?.layout).to(equal(Rect(x: 0, y: 0, width: 100, height: 600)))
                    expect(rectangle3?.layout).to(equal(Rect(x: 100, y: 0, width: 100, height: 600)))
                }
            }
        }

        describe("a row with percentage width rectangles") {
            var app: ScarletUIApplication<Tested>!
            beforeEach {
                app = await ScarletUIApplication(
                    testing: Tested(grow1: 0, grow2: 0, grow3: 0, width: 10%),
                    windowMode: .windowed(width: 600, height: 600)
                )
            }

            context("when creating the row") {
                it("lays out rectangles with parent relative width") {
                    let rectangle1 = await app.view(tagged: "rectangle1")
                    let rectangle2 = await app.view(tagged: "rectangle2")
                    let rectangle3 = await app.view(tagged: "rectangle3")

                    expect(rectangle1?.layout).to(equal(Rect(x: 0, y: 0, width: 60, height: 600)))
                    expect(rectangle2?.layout).to(equal(Rect(x: 60, y: 0, width: 60, height: 600)))
                    expect(rectangle3?.layout).to(equal(Rect(x: 120, y: 0, width: 60, height: 600)))
                }
            }

            context("when a rectangle is hidden") {
                beforeEach {
                    await app.setState("hideRectangle2", to: true)
                }

                it("hides the rectangle") {
                    expect(app).to(notHaveView(tagged: "rectangle2"))
                }

                it("updates layout") {
                    let rectangle1 = await app.view(tagged: "rectangle1")
                    let rectangle3 = await app.view(tagged: "rectangle3")

                    expect(rectangle1?.layout).to(equal(Rect(x: 0, y: 0, width: 60, height: 600)))
                    expect(rectangle3?.layout).to(equal(Rect(x: 60, y: 0, width: 60, height: 600)))
                }
            }
        }

        describe("a row with unequally growing rectangles") {
            var app: ScarletUIApplication<Tested>!
            beforeEach {
                app = await ScarletUIApplication(
                    testing: Tested(grow1: 0.2, grow2: 0.6, grow3: 0.2, width: .auto),
                    windowMode: .windowed(width: 600, height: 600)
                )
            }

            context("when creating the row") {
                it("lays out rectangles according to growth factor") {
                    let rectangle1 = await app.view(tagged: "rectangle1")
                    let rectangle2 = await app.view(tagged: "rectangle2")
                    let rectangle3 = await app.view(tagged: "rectangle3")

                    expect(rectangle1?.layout).to(equal(Rect(x: 0, y: 0, width: 120, height: 600)))
                    expect(rectangle2?.layout).to(equal(Rect(x: 120, y: 0, width: 360, height: 600)))
                    expect(rectangle3?.layout).to(equal(Rect(x: 480, y: 0, width: 120, height: 600)))
                }
            }

            context("when a rectangle is hidden") {
                beforeEach {
                    await app.setState("hideRectangle2", to: true)
                }

                it("hides the rectangle") {
                    expect(app).to(notHaveView(tagged: "rectangle2"))
                }

                it("updates layout") {
                    let rectangle1 = await app.view(tagged: "rectangle1")
                    let rectangle3 = await app.view(tagged: "rectangle3")

                    expect(rectangle1?.layout).to(equal(Rect(x: 0, y: 0, width: 120, height: 600)))
                    expect(rectangle3?.layout).to(equal(Rect(x: 120, y: 0, width: 120, height: 600)))
                }
            }
        }
    }
}
