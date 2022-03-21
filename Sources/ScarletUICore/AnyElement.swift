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

/// A type-erased app, scene or view, used internally to access its properties.
/// TODO: needs to be a class to prevent duplications between `body` and `children` inside `BodyNode`.
public class AnyElement: CustomStringConvertible {
    var element: Any
    var elementType: Any.Type

    var isLeaf: Bool

    var bodyClosure: (Any) -> BodyNode
    var makeClosure: (Any, BodyNode?) -> [ElementOperation]
    var equalsClosure: (Any, AnyElement) -> Bool

    init<V: View>(view: V) {
        self.element = view
        self.elementType = V.self

        self.isLeaf = V.Body.self == Never.self

        self.bodyClosure = { view in
            return BodyNode(of: (view as! V).body)
        }

        self.makeClosure = { view, previous in
            if let previous = previous {
                return V.makeViews(view: (view as! V), previous: (previous.body.element as! V))
            }

            return V.makeViews(view: (view as! V), previous: nil)
        }

        self.equalsClosure = { view, newView in
            return V.equals(lhs: (view as! V), rhs: (newView.element as! V))
        }
    }

    var body: BodyNode {
        return self.bodyClosure(self.element)
    }

    func equals(other: AnyElement) -> Bool {
        // First compare view type
        guard self.elementType == other.elementType else {
            return false
        }

        // Then compare field by field
        return self.equalsClosure(self.element, other)
    }

    func make(previous: BodyNode?) -> [ElementOperation] {
        return self.makeClosure(self.element, previous)
    }

    public var description: String {
        return "AnyElement<\(self.elementType)>"
    }
}
