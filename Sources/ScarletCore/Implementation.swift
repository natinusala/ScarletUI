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

/// The implementation holds the element layout (size, position), attributes as well as all the
/// necessary functions to draw it onscreen.
///
/// All different implementations of the an app make a tree.
public protocol ImplementationNode {
    init(kind: ImplementationKind, displayName: String)

    /// Inserts the given element into this implementation node.
    func insertChild(_ child: ImplementationNode, at position: Int)

    /// Removes the given element from this implementation node.
    func removeChild(at position: Int)
}

/// Kind of an implementation node.
public enum ImplementationKind {
    case app
    case scene
    case view
}

/// Proxy to access an element's implementation in a type-erased manner.
/// TODO: Remove once Swift 5.7 is available and we have unlocked existentials, put the element directly in `MakeOutput`
public struct ImplementationProxy {
    let makeClosure: () -> ImplementationNode?
    let updateClosure: (any ImplementationNode) -> ()

    init<V: View>(view: V) {
        self.makeClosure = {
            return V.makeImplementation(of: view)
        }

        self.updateClosure = { implementation in
            guard let implementation = implementation as? V.Implementation else {
                fatalError("Tried to update an implementation with the wrong view type")
            }

            V.updateImplementation(implementation, with: view)
        }
    }

    init() {
        self.makeClosure = { nil }
        self.updateClosure = { _ in }
    }

    func make() -> ImplementationNode? {
        return self.makeClosure()
    }

    func update(_ implementation: ImplementationNode) {
        self.updateClosure(implementation)
    }
}

extension Never: ImplementationNode {
    public init(kind: ImplementationKind, displayName: String) {
        fatalError()
    }

    public func insertChild(_ child: ImplementationNode, at position: Int) {
        fatalError()
    }

    public func removeChild(at position: Int) {
        fatalError()
    }
}
