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
    @State private var toggle = false

    var body: some Scene {
        Window(title: "ScarletUI Demo", mode: .windowed(width: 800, height: 600)) {
            Row {
                Rectangle(color: .orange).grow()
                Rectangle(color: .blue).grow()
                Rectangle(color: .yellow).grow()
            }
                .padding(50)
                .grow()

            Column {
                Rectangle(color: .red).grow()

                if toggle {
                    Rectangle(color: .green).grow()
                }
            }
                .grow()
                .onGamepadButtonPress(.physical(.dpadUp)) {
                    toggle.toggle()
                }
        }
    }
}
