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
    var body: some Scene {
        Window(title: "ScarletUI Demo") {
            Row {
                Colors()
                    .grow(1.0)

                Column(reverse: true) {
                    Colors()
                        .grow(1.0)
                }
                .grow(1.0)
            }
            .height(100%)
        }
    }
}

struct Colors: View {
    var body: some View {
        Group {
            Rectangle(color: .red)
            Rectangle(color: .green)
            Rectangle(color: .blue)
        }
        .grow(1.0)
    }
}
