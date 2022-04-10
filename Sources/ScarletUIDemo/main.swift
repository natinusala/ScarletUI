import ScarletUI

struct MainView: View {
    var body: some View {
        Text("Hello, World!")
    }
}

let root = ElementGraph(making: MainView())

(root.implementation! as! ViewImplementation).printTree()
