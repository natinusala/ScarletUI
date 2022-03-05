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

/// A view is the building block of an on-screen element. A scene is made
/// of a views tree.
public  protocol View: TreeNodeMetadata {
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

extension View {
    /// Default implementation of `makeViews`: insert or update the view.
    /// Removal is handled by its parent view (`Optional` or `ConditionalView`).
    public static func makeViews(view: Self, previous: Self?) -> ViewOperations {
        debug("Calling View makeViews on \(Self.self) - previous: \(previous == nil ? "no" : "yes")")

        if previous == nil {
            return ViewOperations(insertions: [ViewInsertion(newView: AnyView(view: view), position: 0)])
        }

        return ViewOperations(updates: [ViewUpdate(updatedView: AnyView(view: view), position: 0)])
    }

    /// Default implementation of `viewsCount`: one view, itself.
    public static func viewsCount(view: Self) -> Int {
        return 1
    }
}

extension Never: View {
    public var body: Never {
        fatalError()
    }
}

extension View where Body == Never {
    public var body: Never {
        fatalError()
    }
}
