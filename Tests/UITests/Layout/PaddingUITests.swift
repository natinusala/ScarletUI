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

class PaddingUITests: QuickSpec {
    struct Tested: View {
        let paddingTop: LayoutValue
        let paddingRight: LayoutValue
        let paddingBottom: LayoutValue
        let paddingLeft: LayoutValue

        var body: some View {
            Column {
                Rectangle(color: .black).tag("rectangle1").grow()
                Rectangle(color: .white).tag("rectangle2").grow()
            }
                .padding(
                    top: paddingTop,
                    right: paddingRight,
                    bottom: paddingBottom,
                    left: paddingLeft
                )
                .tag("column")
                .grow()
        }
    }

    override func spec() {
        describe("a row with padding") {
            context("when padding is in dip") {
                it("applies padding") {
                    let app = await ScarletUIApplication(
                        testing: Tested(paddingTop: 40, paddingRight: 50, paddingBottom: 40, paddingLeft: 50),
                        windowMode: .windowed(width: 600, height: 600)
                    )

                    let column = await app.view(tagged: "column")
                    let rectangle1 = await app.view(tagged: "rectangle1")
                    let rectangle2 = await app.view(tagged: "rectangle2")

                    expect(column?.layout).to(equal(Rect(x: 0, y: 0, width: 600, height: 600)))
                    expect(rectangle1?.layout).to(equal(Rect(x: 50, y: 40, width: 500, height: 260)))
                    expect(rectangle2?.layout).to(equal(Rect(x: 50, y: 300, width: 500, height: 260)))
                }
            }

            context("when padding is in percentage") {
                it("applies padding") {
                    let app = await ScarletUIApplication(
                        testing: Tested(paddingTop: 10%, paddingRight: 20%, paddingBottom: 10%, paddingLeft: 20%),
                        windowMode: .windowed(width: 800, height: 600)
                    )

                    let column = await app.view(tagged: "column")
                    let rectangle1 = await app.view(tagged: "rectangle1")
                    let rectangle2 = await app.view(tagged: "rectangle2")

                    expect(column?.layout).to(equal(Rect(x: 0, y: 0, width: 800, height: 600)))
                    expect(rectangle1?.layout).to(equal(Rect(x: 160, y: 80, width: 480, height: 220)))
                    expect(rectangle2?.layout).to(equal(Rect(x: 160, y: 300, width: 480, height: 220)))
                }
            }

            context("when padding is undefined") {
                it("doesn't apply padding") {
                    let app = await ScarletUIApplication(
                        testing: Tested(paddingTop: .undefined, paddingRight: .undefined, paddingBottom: .undefined, paddingLeft: .undefined),
                        windowMode: .windowed(width: 800, height: 600)
                    )

                    let column = await app.view(tagged: "column")
                    let rectangle1 = await app.view(tagged: "rectangle1")
                    let rectangle2 = await app.view(tagged: "rectangle2")

                    expect(column?.layout).to(equal(Rect(x: 0, y: 0, width: 800, height: 600)))
                    expect(rectangle1?.layout).to(equal(Rect(x: 0, y: 0, width: 800, height: 300)))
                    expect(rectangle2?.layout).to(equal(Rect(x: 0, y: 300, width: 800, height: 300)))
                }
            }

            context("when padding is auto") {
                it("doesn't apply padding") {
                    let app = await ScarletUIApplication(
                        testing: Tested(paddingTop: .auto, paddingRight: .auto, paddingBottom: .auto, paddingLeft: .auto),
                        windowMode: .windowed(width: 800, height: 600)
                    )

                    let column = await app.view(tagged: "column")
                    let rectangle1 = await app.view(tagged: "rectangle1")
                    let rectangle2 = await app.view(tagged: "rectangle2")

                    expect(column?.layout).to(equal(Rect(x: 0, y: 0, width: 800, height: 600)))
                    expect(rectangle1?.layout).to(equal(Rect(x: 0, y: 0, width: 800, height: 300)))
                    expect(rectangle2?.layout).to(equal(Rect(x: 0, y: 300, width: 800, height: 300)))
                }
            }

            context("when padding is updated") {
                it("updates padding") {
                    let app = await ScarletUIApplication(
                        testing: Tested(paddingTop: .undefined, paddingRight: .undefined, paddingBottom: .undefined, paddingLeft: .undefined),
                        windowMode: .windowed(width: 600, height: 600)
                    )

                    let column = await app.view(tagged: "column")
                    let rectangle1 = await app.view(tagged: "rectangle1")
                    let rectangle2 = await app.view(tagged: "rectangle2")

                    expect(column?.layout).to(equal(Rect(x: 0, y: 0, width: 600, height: 600)))
                    expect(rectangle1?.layout).to(equal(Rect(x: 0, y: 0, width: 600, height: 300)))
                    expect(rectangle2?.layout).to(equal(Rect(x: 0, y: 300, width: 600, height: 300)))

                    await app.update(with: Tested(paddingTop: 50, paddingRight: 50, paddingBottom: 50, paddingLeft: 50))

                    expect(column?.layout).to(equal(Rect(x: 0, y: 0, width: 600, height: 600)))
                    expect(rectangle1?.layout).to(equal(Rect(x: 50, y: 50, width: 500, height: 250)))
                    expect(rectangle2?.layout).to(equal(Rect(x: 50, y: 300, width: 500, height: 250)))
                }
            }

            context("when padding has different units for different edges") {
                it("applies padding") {
                    let app = await ScarletUIApplication(
                        testing: Tested(paddingTop: .undefined, paddingRight: 10%, paddingBottom: .undefined, paddingLeft: 100),
                        windowMode: .windowed(width: 600, height: 600)
                    )

                    let column = await app.view(tagged: "column")
                    let rectangle1 = await app.view(tagged: "rectangle1")
                    let rectangle2 = await app.view(tagged: "rectangle2")

                    expect(column?.layout).to(equal(Rect(x: 0, y: 0, width: 600, height: 600)))
                    expect(rectangle1?.layout).to(equal(Rect(x: 100, y: 0, width: 440, height: 300)))
                    expect(rectangle2?.layout).to(equal(Rect(x: 100, y: 300, width: 440, height: 300)))
                }
            }
        }
    }
}
