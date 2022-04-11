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

struct Wrapper: ViewModifier {
    func body(content: Content) -> some View {
        Row {
            content
        }
    }
}

extension View {
    func wrapper() -> some View {
        modifier(Wrapper())
    }
}

struct ContentView: View {
    var debug = false
    var double = false

    var body: some View {
        Text("Text")
        .wrapper()
        .wrapper()
        .wrapper()
    }
}

let root = ElementNode(making: ContentView())
root.printGraph()
