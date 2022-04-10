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

import ScarletCore

/// Base class for implementation of all views.
open class ViewImplementation: ElementImplementation, CustomStringConvertible {
    /// Children of this view.
    var children: [ViewImplementation] = []

    /// The view's "display name", used for wireframe mode.
    let displayName: String

    public required init(displayName: String) {
        self.displayName = displayName
    }

    open func insert(child: ElementImplementation, at index: Int) {
        fatalError("insert unimplemented")
    }

    open func remove(at index: Int) {
        fatalError("remove unimplemented")
    }

    public func printTree(indent: Int = 0) {
        let indentString = String(repeating: " ", count: indent)
        print("\(indentString)- \(self)")

        for child in self.children {
            child.printTree(indent: indent + 4)
        }
    }

    public var description: String {
        return self.displayName
    }
}

/// Implementation of all user views.
public class UserViewImplementation: ViewImplementation {

}

public extension View {
    typealias Implementation = UserViewImplementation

    static func updateImplementation(_ implementation: UserViewImplementation, with view: Self) {
        // Nothing to update
    }
}
