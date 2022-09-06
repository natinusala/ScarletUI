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

struct Window<Content: View>: LeafScene {
    let content: Content

    init(@ElementBuilder content: () -> Content) {
        self.content = content()
    }
}

struct ScarletUIDemo: App {
    var body: some Scene {
        Window {
            MainContent()
        }
    }
}

struct MainContent: View {
    var body: some View {
        Text("1")

        Text("2")
            .wrapped()

        Text("3")
    }
}

struct Text: LeafView {
    let text: String

    init(_ text: String) {
        self.text = text
    }

    var debugDescription: String {
        return "Text(text: \(self.text))"
    }
}

struct TextWrapper: ViewModifier {
    func body(content: Content) -> some View {
        Text("Wrapped 1")

        content

        Text("Wrapped 2")

        Text("Wrapped AGAIN")
            .again()
    }
}

struct AgainWrapper: ViewModifier {
    func body(content: Content) -> some View {
        Text("AGAIN1")
        content
        Text("AGAIN2")
    }
}

extension View {
    func again() -> some View {
        return modifier(AgainWrapper())
    }
}

extension View {
    func wrapped() -> some View {
        return modifier(TextWrapper())
    }
}

let app = ScarletUIDemo()
let node = ScarletUIDemo.makeNode(of: app, in: nil, implementationPosition: 0, using: .root())
node.printTree()
