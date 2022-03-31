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
public struct AnyElement: CustomStringConvertible {
    var element: Any
    var elementType: Any.Type

    var isLeaf: Bool

    var makeClosure: (Any) -> GraphValue
    var makeChildrenClosure: (Any) -> ElementChildren
    var staticChildrenCountClosure: () -> Int

    public init<V: View>(view: V) {
        self.element = view
        self.elementType = V.self

        self.isLeaf = V.Body.self == Never.self

        self.makeClosure = { view in
            return V.makeView(view: (view as! V))
        }

        self.makeChildrenClosure = { view in
            return V.makeChildren(view: (view as! V))
        }

        self.staticChildrenCountClosure = {
            return V.staticChildrenCount
        }
    }

    func make() -> GraphValue {
        return self.makeClosure(self.element)
    }

    func makeChildren() -> ElementChildren {
        return self.makeChildrenClosure(self.element)
    }

    var staticChildrenCount: Int {
        return self.staticChildrenCountClosure()
    }

    public var description: String {
        return "AnyElement<\(self.elementType)>"
    }
}
