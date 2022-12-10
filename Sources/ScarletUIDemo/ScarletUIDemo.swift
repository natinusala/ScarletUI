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

let colors = [Color.black, Color.red, Color.orange]

@main
struct ScarletUIDemo: App {
    @State private var color = 0

    var body: some Scene {
        Window(title: "ScarletUI Demo") {
            Rectangle(color: colors[color])
                .grow()
                .onGamepadButtonPress(.dpadUp) {
                    color += 1
                }
                .onGamepadButtonPress(.dpadDown) {
                    color -= 1
                }

            Rectangle(color: .blue)
                .grow()
        }
    }
}