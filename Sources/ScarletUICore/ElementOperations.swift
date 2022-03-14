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

/// Represents the position of a child element inside
/// its parent's expanded list.
typealias ElementPosition = Int

/// An insertion operation.
struct ElementInsertion {
    var newView: AnyElement
    var position: ElementPosition

    func offsetBy(_ offset: Int) -> ElementInsertion {
        return ElementInsertion(newView: self.newView, position: self.position + offset)
    }
}

/// A comparison and update (if needed) operation.
struct ElementUpdate {
    var updatedView: AnyElement
    var position: ElementPosition

    func offsetBy(_ offset: Int) -> ElementUpdate {
        return ElementUpdate(updatedView: self.updatedView, position: self.position + offset)
    }
}

/// A removal operation.
struct ElementRemoval {
    var position: ElementPosition

    func offsetBy(_ offset: Int) -> ElementRemoval {
        return ElementRemoval(position: self.position + offset)
    }
}

/// Operations to perform on an app, scene or view's expanded list to migrate it from
/// its current version to the new one.
public struct ElementOperations {
    var insertions: [ElementInsertion]
    var updates: [ElementUpdate]
    var removals: [ElementRemoval]

    init(
        insertions: [ElementInsertion] = [],
        updates: [ElementUpdate] = [],
        removals: [ElementRemoval] = []
    ) {
        self.insertions = insertions
        self.updates = updates
        self.removals = removals
    }

    /// Returns a new `ElementOperations` with all operations of this instance and
    /// all of the operations of the given instance, offset by the given amount.
    func appendAndOffset(operations: ElementOperations, offset: Int) -> ElementOperations {
        return ElementOperations(
            insertions: self.insertions + operations.insertions.map { $0.offsetBy(offset) },
            updates: self.updates + operations.updates.map { $0.offsetBy(offset) },
            removals: self.removals + operations.removals.map { $0.offsetBy(offset) }
        )
    }

    /// Prints a summary of every operation as debug messages.
    func debugSummary(nodeType: Any.Type) {
        debug("------------------------------------------")
        debug("Update operations summary for \(nodeType)")
        debug("------------------------------------------")

        debug("Updates:")
        for update in self.updates {
            debug("     - \(update.updatedView.elementType) \(update.position)")
        }

        debug("Removals:")
        for removal in self.removals {
            debug("     - \(removal.position)")
        }

        debug("Insertions:")
        for insertion in self.insertions {
            debug("     - \(insertion.newView.elementType) \(insertion.position)")
        }
    }
}
