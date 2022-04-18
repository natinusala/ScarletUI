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
/// All different implementations of an app make a tree.
///
/// The lifecycle of an implementation node is as follows:
///     - `init`
///     - all attributes are set one by one
///         - the `didSet` observer is called for each one if the value is different that the default one
///     - `attributesDidSet` is called once all attributes are set
///     - `deinit`
public protocol ImplementationNode {
    /// Creates a new implementation node for the given kind.
    init(kind: ImplementationKind, displayName: String)

    /// Called right after node creation when all attributes have been set.
    func attributesDidSet()

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
public protocol ImplementationAccessor {
    /// Makes the implementation node if any.
    func makeImplementation() -> ImplementationNode?

    /// Updates the implementation node.
    func updateImplementation(_ implementation: any ImplementationNode)
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

    public func attributesDidSet() {
        fatalError()
    }
}
