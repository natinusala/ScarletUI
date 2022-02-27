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

/// The result of a body property call, aka. all children of a view.
/// TODO: turn `AnyView` into a class then make another step before calling body that translates `TupleView`, `Optional` and `ConditionalView` into counterparts that use `AnyView` instead of `View`, to prevent duplicating views between `body` and `children` in BodyNode (use the same `AnyView` reference for both)
struct BodyNode {
    var body: AnyView

    var mountedViews = [MountedView]()

    init<V: View>(of body: V) {
        self.body = AnyView(view: body)
    }

    private func makeViews(previous: BodyNode?) -> ViewOperations {
        if let previous = previous {
            if self.body.viewType != previous.body.viewType {
                fatalError("`makeViews(previous:)` called with two bodies of a different type: `\(self.body.viewType)` and `\(previous.body.viewType)`")
            }
        }

        return self.body.makeViews(previous: previous)
    }

    /// Compare the node to the next one and updates the mounted views to apply the changes.
    mutating func update(next: BodyNode) {
        // Call `makeViews` on the new node giving ourselves as the previous node
        // to get the list of changes to apply
        self.applyOperations(next.makeViews(previous: self))

        // Update `body` property once every operation is applied
        self.body = next.body
    }

    /// Performs the initial mount: call `makeViews` on `self` without a previous node and apply changes.
    mutating func initialMount() {
        debug("Performing initial mount on \(self.body.viewType)")

        self.applyOperations(self.makeViews(previous: nil))

        debug("Got \(self.mountedViews.count) mounted views after applying operations of initial mount")
    }

    /// Mutates the body node to apply given operations.
    private mutating func applyOperations(_ operations: ViewOperations) {
        // Avoid mutating the list to preserve the original views positions,
        // otherwise we won't be able to apply all operations:
        //  - Process updates
        //  - Mark all views that need to be removed
        //  - Process insertions, this will mutate the list but it doesn't matter anymore
        //  - Filter the list to remove those marked previously

        // Start with updates
        for update in operations.updates {
            debug("  -> Updating \(update.updatedView.viewType) at position \(update.position)")
            self.updateView(at: update.position, with: update.updatedView)
        }

        // Mark removals
        for removal in operations.removals {
            debug("  -> Removing \(self.mountedViews[removal.position].view.viewType)")
            self.mountedViews[removal.position].toBeRemoved = true
        }

        // Process insertions
        for insertion in operations.insertions {
            debug("  -> Inserting \(insertion.newView.viewType)")
            self.insertView(view: insertion.newView, at: insertion.position)
        }

        // Sweep the list for removed views
        self.mountedViews = self.mountedViews.filter { !$0.toBeRemoved }
    }

    /// Updates the view at the given position with its new version.
    mutating func updateView(at position: ViewPosition, with newView: AnyView) {
        let mountedView = self.mountedViews[position]

        // Compare the two views to detect any change
        debug("Comparing \(mountedView.view.viewType) with \(newView.viewType)")
        guard !mountedView.view.equals(other: newView) else {
            debug("They are equal")
            return
        }

        debug("They are different")

        // If they changed, give the new mounted view its new view
        mountedView.view = newView
    }

    /// Inserts the given view at the given position.
    mutating func insertView(view: AnyView, at position: ViewPosition) {
        debug("Inserting \(view.description) at position \(position)")

        let mountedView = MountedView(view: view)

        // Perform initial mount
        if !mountedView.view.isLeaf {
            mountedView.children = mountedView.view.body
            mountedView.children?.initialMount()
        }

        // Insert the view
        self.mountedViews.insert(mountedView, at: position)
    }

    func printTree(indent: Int = 0) {
        var str = String(repeating: " ", count: indent)
        debug("\(str)BodyNode<\(self.body.viewType)>")
        str += "- "

        for mountedView in self.mountedViews {
            debug("\(str)\(mountedView.view.viewType)")
            mountedView.children?.printTree(indent: indent + 4)
        }
    }
}
