import Foundation

import ScarletUI

struct IdModifier: ViewModifier {
    let id: String
}

extension View {
    func id(_ id: String) -> some View {
        return modifier(IdModifier(id: id))
    }
}

struct Wrapper: ViewModifier {
    var contain: Bool

    func body(content: Content) -> some View {
        if contain {
            content
        } else {
            Text("Missing content!")
        }
    }
}

extension View {
    func wrapper(contain: Bool) -> some View {
        return modifier(Wrapper(contain: contain))
    }
}

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

struct MainContent: View {
    var contain: Bool

    var body: some View {
        Row {
            Text("Hello world")
                .id("helloworl")
                .wrapper(contain: contain)
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

    var flip1 = true
    var flip2 = true

    var contain = true

    var body: some View {
        Row {
            if !collapsed {
                Sidebar(title: title, debug: debug)
                    .id("sidebar")
            }

            MainContent(contain: contain)

            if flip1 && flip2 {
                Text("Flip 1")
                Text("Flip 2")
            } else if flip1 {
                Text("Flip 1")
            } else if flip2 {
                Divider()
            } else {
                Divider()
                Divider()

                if debug {
                    Text("Debug Menu")
                        .id("identifier")
                }
            }
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

print(" --------------- Should remove TupleView2<Text, Text> and insert Text ---------------")

updated = ContentView(collapsed: false, title: "Updated Sidebar Title", debug: false, flip2: false)
root.update(with: updated)

print(" --------------- Should remove Text and insert Divider, Divider ---------------")

updated = ContentView(collapsed: false, title: "Updated Sidebar Title", debug: false, flip1: false, flip2: false)
root.update(with: updated)

print(" --------------- Should add Text ---------------")

updated = ContentView(collapsed: false, title: "Updated Sidebar Title", debug: true, flip1: false, flip2: false)
root.update(with: updated)

print(" --------------- Modifiers ---------------")

root.printGraph()

print(" --------------- Should remove and insert Text ---------------")

updated = ContentView(collapsed: false, title: "Updated Sidebar Title", debug: true, flip1: false, flip2: false, contain: false)
root.update(with: updated)
