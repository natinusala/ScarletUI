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

/// An element that has an associated implementation.
public protocol Implementable {
    /// The type of this view's implementation.
    /// Set to `Never` if there is none.
    associatedtype Implementation: ImplementationNode

    /// Updates an implementation node with the given view.
    static func updateImplementation(_ implementation: Implementation, with view: Self)
}

public extension Implementable {
    static var substantial: Bool {
        return Self.Implementation.self != Never.self
    }
}

/// The implementation holds the element layout (size, position), attributes as well as all the
/// necessary functions to draw it onscreen.
///
/// All different implementations of an app make a tree.
///
/// The lifecycle of an implementation node is as follows:
///     - the node is created
///         - `init`
///         - all attributes are set one by one
///             - the `didSet` observer is called for each one if the value is different that the default one
///         - `attributesDidSet` is called once all attributes are set
///     - the node is inserted into its parent node
///     - the app runs and eventually the node gets removed
///         - the node is removed from its parent node
///         - `deinit`
public protocol ImplementationNode {
    var displayName: String { get }

    /// Creates a new implementation node.
    init(displayName: String)

    /// Called right after node creation when all attributes have been set.
    func attributesDidSet()

    /// Inserts the given element into this implementation node.
    func insertChild(_ child: ImplementationNode, at position: Int)

    /// Removes the given element from this implementation node.
    func removeChild(at position: Int)
}
