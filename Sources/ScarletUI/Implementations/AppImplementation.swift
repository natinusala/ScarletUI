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

import Backtrace

import ScarletCore

/// Implementation for all apps.
open class AppImplementation: ImplementationNode, CustomStringConvertible {
    /// App display name for debugging purposes.
    let displayName: String

    /// Children of this app.
    var children: [SceneImplementation] = []

    public required init(kind: ImplementationKind, displayName: String) {
        guard kind == .app else {
            fatalError("Tried to create a `ViewImplementation` with kind \(kind)")
        }

        self.displayName = displayName
    }

    public func insertChild(_ child: ImplementationNode, at position: Int) {
        guard let child = child as? SceneImplementation else {
            fatalError("Cannot add \(type(of: child)) as child of `AppImplementation`")
        }

        self.children.insert(child, at: position)
    }

    public func removeChild(at position: Int) {
        self.children.remove(at: position)
    }

    /// Runs the app until closed by the user.
    func run() {
        self.printTree()
    }

    open func attributesDidSet() {
        // Nothing by default
    }

    public var description: String {
        return self.displayName
    }

    func printTree(indent: Int = 0) {
        let indentString = String(repeating: " ", count: indent)
        print("\(indentString)- \(self.description) (\(Self.self))")

        for child in self.children {
            child.printTree(indent: indent + 4)
        }
    }
}

public extension App {
    /// Default implementation for user apps.
    typealias Implementation = AppImplementation
}

public extension App {
    static func main() {
        Backtrace.install()

        let app = Self.init()
        let root = ElementGraph(parent: nil, position: 0, making: app)

        (root.implementation as! AppImplementation).run()
    }
}
