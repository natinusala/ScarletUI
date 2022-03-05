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
public struct ViewOperations {
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
