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

// This file contains every struct to describe a view's body (except for TupleView that's generated in a separate file),
// as well as the result builder to glue everything together.

/// Result builder for a view's body.
@resultBuilder
struct ViewBuilder {
    /// Builds a block for an empty view. Returns an optional view with `nil` as value.
    static func buildBlock() -> View? {
        return nil
    }

    /// Builds a block for an optional view. Can return the optional view directly thanks
    /// to the `Optional` extension.
    static func buildIf<Content: View>(_ content: Content?) -> Content? {
        return content
    }

    /// Builds a block for a single view.
    static func buildBlock<Content: View>(_ content: Content) -> Content {
        return content
    }
}

/// `Optional` extension to add `View` conformance.
extension Optional: View, EquatableStruct, TreeNodeMetadata where Wrapped: View {
    typealias Body = Never

    static func makeViews(view: Self, previous: Self?) -> ViewOperations {
        debug("Calling Optional makeViews on \(Self.self) - previous? \(previous == nil ? "no" : "yes")")

        // If there is no previous node and we have a value, always insert (by giving no previous node)
        guard let previous = previous else {
            switch view {
                case .none:
                    return ViewOperations()
                case let .some(view):
                    return Wrapped.makeViews(view: view, previous: nil)
            }
        }

        // Otherwise check every different possibility
        switch (view, previous) {
            // Both are `.none` -> nothing has changed
            case (.none, .none):
                return ViewOperations()
            // Both are `.some` -> call `makeViews` recursively to have an update operation
            case let (.some(view), .some(previous)):
                return Wrapped.makeViews(view: view, previous: previous)
            // Some to none -> remove the view
            case let (.none, .some(view)):
                // Remove every view from 0 to wrapped views count
                let toRemoveCount = Wrapped.viewsCount(view: view)
                return ViewOperations(removals: Array(0..<toRemoveCount).map { ViewRemoval(position: $0) })
            // None to some -> call `makeViews` recursively without a previous node to have an insert operation
            case let (.some(view), .none):
                return Wrapped.makeViews(view: view, previous: nil)
        }
    }

    static func viewsCount(view: Self) -> Int {
        switch view {
            case .none:
                return 0
            case let .some(view):
                return Wrapped.viewsCount(view: view)
        }
    }

    static func equals(lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
            case (.none, .some), (.some, .none):
                return false
            case (.none, .none):
                return true
            case let (.some(lhs), .some(rhs)):
                return Wrapped.equals(lhs: lhs, rhs: rhs)
        }
    }
}
