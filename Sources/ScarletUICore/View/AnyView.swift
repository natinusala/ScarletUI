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

/// A type-erased view, used internally to access a view's properties.
/// TODO: needs to be a class to prevent duplications between `body` and `children` inside `BodyNode`.
class AnyView: CustomStringConvertible {
    var view: TreeNodeMetadata
    var viewType: Any.Type

    var isLeaf: Bool

    internal var bodyClosure: (Any) -> BodyNode
    internal var makeViewsClosure: (Any, BodyNode?) -> ViewOperations
    internal var equalsClosure: (Any, AnyView) -> Bool

    init<V: View>(view: V) {
        self.view = view
        self.viewType = V.self

        self.isLeaf = V.Body.self == Never.self

        self.bodyClosure = { view in
            return BodyNode(of: (view as! V).body)
        }

        self.makeViewsClosure = { view, previous in
            if let previous = previous {
                return V.makeViews(view: (view as! V), previous: (previous.body.view as! V))
            }

            return V.makeViews(view: (view as! V), previous: nil)
        }

        self.equalsClosure = { view, newView in
            return V.equals(lhs: (view as! V), rhs: (newView.view as! V))
        }
    }

    var body: BodyNode {
        return self.bodyClosure(self.view)
    }

    func equals(other: AnyView) -> Bool {
        // First compare view type
        guard self.viewType == other.viewType else {
            return false
        }

        // Then compare field by field
        return self.equalsClosure(self.view, other)
    }

    func makeViews(previous: BodyNode?) -> ViewOperations {
        return self.makeViewsClosure(self.view, previous)
    }

    var description: String {
        return "AnyView<\(self.viewType)>"
    }
}
