/**
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

/// A view is the building block of an on-screen element. A scene is made
/// of a views tree.
protocol View: TreeNodeMetadata {
    /// The type of this view's body.
    associatedtype Body: View

    /// This view's body.
    var body: Body { get }

    /// Compares this view with its previous version and tells what needs to be done
    /// to the expanded views list in order to migrate from the old version to the new one.
    ///
    /// Ranges in returned operations are relative to this view's expanded list.
    /// If called recursively, the caller needs to offset the ranges to translate them
    /// and make them fit into its own expanded list.
    ///
    /// Order is not important. Positions should match the initial expanded list, without
    /// considering previous operations that might mutate the list and shuffle positions.
    static func makeViews(view: Self, previous: Self?) -> ViewOperations

    /// Returns the number of expanded views that make that view.
    static func viewsCount(view: Self) -> Int
}

/// Represents the position of a child view inside
/// its parent's expanded list.
typealias ViewPosition = Int

/// An insertion operation.
struct ViewInsertion {
    var newView: AnyView
    var position: ViewPosition

    func offsetBy(_ offset: Int) -> ViewInsertion {
        return ViewInsertion(newView: self.newView, position: self.position + offset)
    }
}

/// A comparison and update (if needed) operation.
struct ViewUpdate {
    var updatedView: AnyView
    var position: ViewPosition

    func offsetBy(_ offset: Int) -> ViewUpdate {
        return ViewUpdate(updatedView: self.updatedView, position: self.position + offset)
    }
}

/// A removal operation.
struct ViewRemoval {
    var position: ViewPosition

    func offsetBy(_ offset: Int) -> ViewRemoval {
        return ViewRemoval(position: self.position + offset)
    }
}

/// Operations to perform on a view's expanded list to migrate it from
/// its current version to the new one.
struct ViewOperations {
    var insertions: [ViewInsertion]
    var updates: [ViewUpdate]
    var removals: [ViewRemoval]

    init(insertions: [ViewInsertion] = [], updates: [ViewUpdate] = [], removals: [ViewRemoval] = []) {
        self.insertions = insertions
        self.updates = updates
        self.removals = removals
    }

    /// Returns a new `ViewOperations` with all operations of this instance and
    /// all of the operations of the given instance, offset by the given amount.
    func appendAndOffset(operations: ViewOperations, offset: Int) -> ViewOperations {
        return ViewOperations(
            insertions: self.insertions + operations.insertions.map { $0.offsetBy(offset) },
            updates: self.updates + operations.updates.map { $0.offsetBy(offset) },
            removals: self.removals + operations.removals.map { $0.offsetBy(offset) }
        )
    }
}

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

/// A mounted view.
/// Must be a class for the state setter / body refresh process: the mounted view needs to escape
/// in the setter closure to be able to update itself (replace any changed child).
class MountedView {
    var view: AnyView {
        didSet {
            // If the view changes, call body again and compare the new body node
            // with the previous one
            let newBody = self.view.body
            self.children?.update(next: newBody)
        }
    }

    /// The body node corresponding to this's view body.
    var children: BodyNode?

    /// Set to `true` to have this view be removed when possible.
    var toBeRemoved = false

    init(view: AnyView) {
        self.view = view
    }
}

extension View {
    /// Default implementation of `makeViews`: insert or update the view.
    /// Removal is handled by its parent view (`Optional` or `ConditionalView`).
    static func makeViews(view: Self, previous: Self?) -> ViewOperations {
        debug("Calling View makeViews on \(Self.self) - previous: \(previous == nil ? "no" : "yes")")

        if previous == nil {
            return ViewOperations(insertions: [ViewInsertion(newView: AnyView(view: view), position: 0)])
        }

        return ViewOperations(updates: [ViewUpdate(updatedView: AnyView(view: view), position: 0)])
    }

    /// Default implementation of `viewsCount`: one view, itself.
    static func viewsCount(view: Self) -> Int {
        return 1
    }
}

extension Never: View {
    var body: Never {
        fatalError()
    }
}

extension View where Body == Never {
    var body: Never {
        fatalError()
    }
}
