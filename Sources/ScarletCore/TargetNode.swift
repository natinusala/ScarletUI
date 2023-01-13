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

/// An element that has an associated target.
public protocol Targetable {
    /// The type of this view's target.
    /// Set to `Never` if there is none.
    associatedtype Target: TargetNode

    /// Updates a target node with the given view.
    static func updateTarget(_ target: Target, with view: Self)
}

public extension Targetable {
    static var substantial: Bool {
        return Self.Target.self != Never.self
    }
}

/// The target is the direct output of ScarletCore. Running the core on an element
/// creates a target node and binds it to the element. The target node is persisted for the entire
/// lifetime of the element, and is removed when the element is also removed from its own tree.
///
/// All target nodes of an app make a tree (the "target tree"), that resides next to the "elements" tree.
///
/// The lifecycle of a target node is as follows:
///     - the node is created
///         - `init`
///         - all attributes are set one by one
///             - the `didSet` observer is called for each one if the value is different that the default one
///         - `attributesDidSet` is called once all attributes are set
///     - the node is inserted into its parent node
///     - the app runs and eventually the node gets removed
///         - the node is removed from its parent node
///         - `deinit`
public protocol TargetNode: CustomStringConvertible {
    /// Display name for debugging purposes.
    /// Contains the name of the underlying element struct.
    var displayName: String { get }

    /// Creates a new target node.
    init(displayName: String)

    /// Called right after node creation when all attributes have been set.
    func attributesDidSet()

    /// Inserts the given element into this target node.
    func insertChild(_ child: TargetNode, at position: Int)

    /// Removes the given element from this target node.
    func removeChild(at position: Int)
}

public extension TargetNode {
    var description: String {
        return self.displayName
    }
}
