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

/// The result of a body property call, aka. all children of an app, scene or view.
/// TODO: turn `AnyElement` into a class then make another step before calling body that translates `TupleView`, `Optional` and `ConditionalView` into counterparts that use `AnyElement` instead of `View`, to prevent duplicating views between `body` and `children` in BodyNode (use the same `AnyElement` reference for both)
struct BodyNode {
    var body: AnyElement

    var mountedElements = [MountedElement]()

    init<V: View>(of body: V) {
        self.body = AnyElement(view: body)
    }

    private func makeViews(previous: BodyNode?) -> ElementOperations {
        if let previous = previous {
            if self.body.elementType != previous.body.elementType {
                fatalError("`makeViews(previous:)` called with two bodies of a different type: `\(self.body.elementType)` and `\(previous.body.elementType)`")
            }
        }

        return self.body.make(previous: previous)
    }

    /// Compare the node to the next one and updates the mounted elements to apply the changes.
    mutating func update(next: BodyNode) {
        // Call `makeViews` on the new node giving ourselves as the previous node
        // to get the list of changes to apply
        let operations = next.makeViews(previous: self)

        operations.debugSummary(nodeType: self.body.elementType)

        self.applyOperations(operations)

        // Update `body` property once every operation is applied
        self.body = next.body
    }

    /// Performs the initial mount: call `makeViews` on `self` without a previous node and apply changes.
    mutating func initialMount() {
        debug("Performing initial mount on \(self.body.elementType)")

        self.applyOperations(self.makeViews(previous: nil))

        debug("Got \(self.mountedElements.count) mounted elements after applying operations of initial mount")
    }

    /// Mutates the body node to apply given operations.
    private mutating func applyOperations(_ operations: ElementOperations) {
        // Avoid mutating the list to preserve the original elements positions,
        // otherwise we won't be able to apply all operations:
        //  - Process updates
        //  - Mark all elements that need to be removed
        //  - Process insertions, this will mutate the list but it doesn't matter anymore
        //  - Filter the list to remove those marked previously

        // Start with updates
        for update in operations.updates {
            debug("  -> Updating \(update.updatedView.elementType) at position \(update.position)")
            self.updateElement(at: update.position, with: update.updatedView)
        }

        // Mark removals
        for removal in operations.removals {
            debug("  -> Removing \(self.mountedElements[removal.position].element.elementType)")
            self.mountedElements[removal.position].toBeRemoved = true
        }

        // Process insertions
        for insertion in operations.insertions {
            debug("  -> Inserting \(insertion.newView.elementType)")
            self.insertElement(element: insertion.newView, at: insertion.position)
        }

        // Sweep the list for removed elements
        self.mountedElements = self.mountedElements.filter { !$0.toBeRemoved }
    }

    /// Updates the element at the given position with its new version.
    mutating func updateElement(at position: ElementPosition, with newElement: AnyElement) {
        let mountedView = self.mountedElements[position]

        // Compare the two elements to detect any change
        debug("Comparing \(mountedView.element.elementType) with \(newElement.elementType)")
        guard !mountedView.element.equals(other: newElement) else {
            debug("They are equal")
            return
        }

        debug("They are different")

        // If they changed, give the new mounted element its new element
        mountedView.element = newElement
    }

    /// Inserts the given element at the given position.
    mutating func insertElement(element: AnyElement, at position: ElementPosition) {
        debug("Inserting \(element.description) at position \(position)")

        let mountedView = MountedElement(element: element)

        // Perform initial mount
        if !mountedView.element.isLeaf {
            mountedView.children = mountedView.element.body
            mountedView.children?.initialMount()
        }

        // Insert the element
        self.mountedElements.insert(mountedView, at: position)
    }

    func printTree(indent: Int = 0) {
        var str = String(repeating: " ", count: indent)
        debug("\(str)BodyNode<\(self.body.elementType)>")
        str += "- "

        for mountedView in self.mountedElements {
            debug("\(str)\(mountedView.element.elementType)")
            mountedView.children?.printTree(indent: indent + 4)
        }
    }
}
