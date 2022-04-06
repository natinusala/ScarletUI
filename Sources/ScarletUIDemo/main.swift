import Foundation

import ScarletUI

struct Text: View {
    typealias Body = Never

    let text: String

    init(_ text: String) {
        self.text = text
    }
}

struct Divider: View {
    typealias Body = Never
}

struct Content: View {
    var body: some View {
        Row {
            Text("Hello world")
        }
    }
}

struct Sidebar: View {
    var title: String
    var debug: Bool

    var body: some View {
        Row {
            Text(title)
            Text("Logged in as FooBar")

            Divider()

            Text("Main Menu")
            Text("About")

            if debug {
                Divider()

                Text("Debug Menu")
            }
        }
    }
}

struct ContentView: View {
    var collapsed = true
    var title = "Sidebar Title"
    var debug = false

    var body: some View {
        Row {
            if !collapsed {
                Sidebar(title: title, debug: debug)
            }

            Content()
        }
    }
}

let root = ElementNode(making: ContentView())

print(" --------------- Should insert Sidebar ---------------")

var updated = ContentView(collapsed: false)
root.update(with: updated)

print(" --------------- Should remove Sidebar ---------------")

updated = ContentView(collapsed: true)
root.update(with: updated)

print(" --------------- Should say that ContentView is unchanged ---------------")

updated = ContentView(collapsed: true)
root.update(with: updated)

print(" --------------- Should update all of Sidebar (don't print anything yet) ---------------")

updated = ContentView(collapsed: true, title: "Updated Sidebar Title")
root.update(with: updated)

print(" --------------- Should insert sidebar back with divider and test ---------------")

updated = ContentView(collapsed: false, title: "Updated Sidebar Title", debug: true)
root.update(with: updated)

print(" --------------- Should remove divider and text ---------------")

updated = ContentView(collapsed: false, title: "Updated Sidebar Title", debug: false)
root.update(with: updated)
