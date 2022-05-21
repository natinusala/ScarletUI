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

import ScarletUI

@main
struct ScarletUIDemo: App {
    @State private var column1Pos = 0
    @State private var column2Pos = 0

    var body: some Scene {
        return Window(title: "ScarletUI Demo") {
            Row {
                RectangleStack(color: .green, position: column1Pos).grow()
                RectangleStack(color: .blue, position: column2Pos).grow()
            }
            .height(100%)
            .onGamepadButtonPress { button in
                switch button {
                    case .dpadLeft:
                        column1Pos -= 1
                    case .dpadRight:
                        column1Pos += 1
                    case .dpadUp:
                        column2Pos -= 1
                    case .dpadDown:
                        column2Pos += 1
                    default:
                        break
                }
            }
        }
    }
}

struct RectangleStack: View {
    let color: Color
    let position: Int

    var body: some View {
        Column {
            Rectangle(color: position == 0 ? color : .black).grow()
            Rectangle(color: position == 1 ? color : .black).grow()
            Rectangle(color: position == 2 ? color : .black).grow()
        }.grow()
    }
}
