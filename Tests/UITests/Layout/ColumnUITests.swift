/*
   Copyright 2023 natinusala

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

class ColumnUITests: QuickSpec {
    struct Tested: View {
        let grow1: Float
        let grow2: Float
        let grow3: Float
        let height: LayoutValue

        @State private var hideRectangle2 = false

        var body: some View {
            Column {
                Rectangle(color: .red)
                    .grow(grow1)
                    .height(height)
                    .tag("rectangle1")

                if !hideRectangle2 {
                    Rectangle(color: .green)
                        .grow(grow2)
                        .height(height)
                        .tag("rectangle2")
                }

                Rectangle(color: .blue)
                    .grow(grow3)
                    .height(height)
                    .tag("rectangle3")
            }.grow()
        }
    }

    override func spec() {
        describe("a column with equally growing rectangles") {
            var app: ScarletUIApplication<Tested>!
            beforeEach {
                app = await ScarletUIApplication(
                    testing: Tested(grow1: 1.0, grow2: 1.0, grow3: 1.0, height: .auto),
                    windowMode: .windowed(width: 600, height: 600)
                )
            }

            context("when creating the column") {
                it("lays out rectangles equally") {
                    let rectangle1 = await app.view(tagged: "rectangle1")
                    let rectangle2 = await app.view(tagged: "rectangle2")
                    let rectangle3 = await app.view(tagged: "rectangle3")

                    expect(rectangle1?.layout).to(equal(Rect(x: 0, y: 0, width: 600, height: 200)))
                    expect(rectangle2?.layout).to(equal(Rect(x: 0, y: 200, width: 600, height: 200)))
                    expect(rectangle3?.layout).to(equal(Rect(x: 0, y: 400, width: 600, height: 200)))
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

                    expect(rectangle1?.layout).to(equal(Rect(x: 0, y: 0, width: 600, height: 300)))
                    expect(rectangle3?.layout).to(equal(Rect(x: 0, y: 300, width: 600, height: 300)))
                }
            }
        }

        describe("a column with fixed height rectangles") {
            var app: ScarletUIApplication<Tested>!
            beforeEach {
                app = await ScarletUIApplication(
                    testing: Tested(grow1: 0, grow2: 0, grow3: 0, height: 100),
                    windowMode: .windowed(width: 600, height: 600)
                )
            }

            context("when creating the column") {
                it("lays out rectangles with fixed height") {
                    let rectangle1 = await app.view(tagged: "rectangle1")
                    let rectangle2 = await app.view(tagged: "rectangle2")
                    let rectangle3 = await app.view(tagged: "rectangle3")

                    expect(rectangle1?.layout).to(equal(Rect(x: 0, y: 0, width: 600, height: 100)))
                    expect(rectangle2?.layout).to(equal(Rect(x: 0, y: 100, width: 600, height: 100)))
                    expect(rectangle3?.layout).to(equal(Rect(x: 0, y: 200, width: 600, height: 100)))
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

                    expect(rectangle1?.layout).to(equal(Rect(x: 0, y: 0, width: 600, height: 100)))
                    expect(rectangle3?.layout).to(equal(Rect(x: 0, y: 100, width: 600, height: 100)))
                }
            }
        }

        describe("a column with percentage width rectangles") {
            var app: ScarletUIApplication<Tested>!
            beforeEach {
                app = await ScarletUIApplication(
                    testing: Tested(grow1: 0, grow2: 0, grow3: 0, height: 10%),
                    windowMode: .windowed(width: 600, height: 600)
                )
            }

            context("when creating the column") {
                it("lays out rectangles with parent relative width") {
                    let rectangle1 = await app.view(tagged: "rectangle1")
                    let rectangle2 = await app.view(tagged: "rectangle2")
                    let rectangle3 = await app.view(tagged: "rectangle3")

                    expect(rectangle1?.layout).to(equal(Rect(x: 0, y: 0, width: 600, height: 60)))
                    expect(rectangle2?.layout).to(equal(Rect(x: 0, y: 60, width: 600, height: 60)))
                    expect(rectangle3?.layout).to(equal(Rect(x: 0, y: 120, width: 600, height: 60)))
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

                    expect(rectangle1?.layout).to(equal(Rect(x: 0, y: 0, width: 600, height: 60)))
                    expect(rectangle3?.layout).to(equal(Rect(x: 0, y: 60, width: 600, height: 60)))
                }
            }
        }

        describe("a column with unequally growing rectangles") {
            var app: ScarletUIApplication<Tested>!
            beforeEach {
                app = await ScarletUIApplication(
                    testing: Tested(grow1: 0.2, grow2: 0.6, grow3: 0.2, height: .auto),
                    windowMode: .windowed(width: 600, height: 600)
                )
            }

            context("when creating the column") {
                it("lays out rectangles according to growth factor") {
                    let rectangle1 = await app.view(tagged: "rectangle1")
                    let rectangle2 = await app.view(tagged: "rectangle2")
                    let rectangle3 = await app.view(tagged: "rectangle3")

                    expect(rectangle1?.layout).to(equal(Rect(x: 0, y: 0, width: 600, height: 120)))
                    expect(rectangle2?.layout).to(equal(Rect(x: 0, y: 120, width: 600, height: 360)))
                    expect(rectangle3?.layout).to(equal(Rect(x: 0, y: 480, width: 600, height: 120)))
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

                    expect(rectangle1?.layout).to(equal(Rect(x: 0, y: 0, width: 600, height: 120)))
                    expect(rectangle3?.layout).to(equal(Rect(x: 0, y: 120, width: 600, height: 120)))
                }
            }
        }
    }
}
