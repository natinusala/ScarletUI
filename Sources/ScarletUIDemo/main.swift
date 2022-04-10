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

struct Wrapper: ViewModifier {
    func body(content: Content) -> some View {
        Column {
            Text("Wrapper")
            Divider()
            content
        }
    }
}

extension View {
    func wrapper() -> some View {
        self.modifier(Wrapper())
    }
}

struct ContentView: View {
    var debug = false
    var double = false

    var body: some View {
        Group {
            Text("Text 1")
            Text("Text 2")
            Text("Text 3")
        }
            .wrapper()
    }
}

let root = ElementNode(making: ContentView())
root.printGraph()
