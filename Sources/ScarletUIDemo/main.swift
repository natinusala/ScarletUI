// import Foundation

// import ScarletUI

// struct Image: View {
//     typealias Body = Never
// }

// struct Text: View {
//     let text: String

//     init(_ text: String) {
//         self.text = text
//     }
// }

// struct Content: View {
//     var body: some View {
//         Text("Hello, world!")
//     }
// }

// struct Divider: View {
//     typealias Body = Never
// }

// struct Sidebar: View {
//     let debug: Bool

//     var body: some View {
//         Row {
//             Text("Item 1")
//             Text("Item 2")
//             Text("Item 3")

//             Divider()

//             Text("Item 1")
//             Text("Item 2")
//             Text("Item 3")

//             if debug {
//                 Divider()

//                 Text("- Debug mode enabled -")
//             }
//         }
//     }
// }

// struct MainView: View {
//     let expanded: Bool

//     let debug: Bool

//     var body: some View {
//         if expanded {
//             Sidebar(debug: debug)
//         }

//         Column {
//             Header()
//             Content()
//             Footer()
//         }

//         if debug {
//             Sidebar(debug: false)
//         } else {
//             Column {
//                 Text("Debug sidebar disabled")
//             }
//         }
//     }
// }

// struct Footer: View {
//     var body: some View {
//         Row {
//             Image()
//             Text("Header")
//             Image()
//         }
//     }
// }

// struct Header: View {
//     var body: some View {
//         Row {
//             Image()
//             Text("Header")
//         }
//     }
// }

// // ----------------------------

// let root = MainView(expanded: false, debug: false)

// let graph = ElementGraph(
//     mounting: MainView.makeView(view: root),
//     with: AnyElement(view: root)
// )

// // graph.printTree()
// print("-------------")

// // ----------------------------

// var newView = MainView(expanded: true, debug: false)

// graph.updateValue(
//     newValue: MainView.makeView(view: newView),
//     with: AnyElement(view: newView)
// )

// // graph.printTree()
// print("-------------")

// // ----------------------------

// newView = MainView(expanded: true, debug: true)

// graph.updateValue(
//     newValue: MainView.makeView(view: newView),
//     with: AnyElement(view: newView)
// )

// // graph.printTree()
// print("-------------")

// newView = MainView(expanded: true, debug: true)

// graph.updateValue(
//     newValue: MainView.makeView(view: newView),
//     with: AnyElement(view: newView)
// )

// print("-------------")

// newView = MainView(expanded: true, debug: false)

// graph.updateValue(
//     newValue: MainView.makeView(view: newView),
//     with: AnyElement(view: newView)
// )

// print("-------------")
