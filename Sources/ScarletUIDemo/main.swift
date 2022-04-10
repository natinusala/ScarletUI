import Foundation

import Backtrace
import ScarletUI

Backtrace.install()

struct Text: View {
    typealias Body = Never

    let text: String

    init(_ text: String) {
        self.text = text
    }
}

struct Image: View {
    let src: String

    init(_ src: String) {
        self.src = src
    }

    var body: some View {
        Text(src)
    }
}

struct Divider: View {
    typealias Body = Never
}

struct Divide: ViewModifier {
    var double: Bool

    func body(content: Content) -> some View {
        let _ = print("Calling Divide body")

        Divider()
        content
        Divider()

        if double {
            Text("Make it double")
        }
    }
}

extension View {
    func divide(double: Bool) -> some View {
        self.modifier(Divide(double: double))
    }
}

struct Sidebar: View {
    let debug: Bool

    var body: some View {
        let _ = print("Calling Sidebar body")

        Column {
            Text("Main Content")
            Divider()
            Text("Bonus Content")

            if debug {
                Divider()
                Text("Debug")
            }
        }
    }
}

struct ThreeTimes: ViewModifier {
    func body(content: Content) -> some View {
        content
        content
        content
    }
}

extension View {
    func threeTimes() -> some View {
        self.modifier(ThreeTimes())
    }
}

struct ContentView: View {
    var debug = false
    var double = false

    var body: some View {
        Row {
            Sidebar(debug: debug)
                .divide(double: double)

            Image("picture1")
                .threeTimes()
        }
    }
}

let root = ElementNode(making: ContentView())
root.printGraph()

print("---- Should not do anything ----")

root.update(with: ContentView())

print("---- Should add Divider, Text only, without calling modifier body ----")

root.update(with: ContentView(debug: true))

print("---- Modify modifier - should call its body but NOT the content body ----")

root.update(with: ContentView(debug: true, double: true))

print("---- Both bodies are called - Divider, Text is removed + Text is removed ----")

root.update(with: ContentView(debug: false, double: false))

root.printGraph()
