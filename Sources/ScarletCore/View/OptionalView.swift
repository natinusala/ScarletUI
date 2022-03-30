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

/// `Optional` extension to add `View` conformance.
extension Optional: View where Wrapped: View {
    public typealias Body = Never

    public static func makeViews(view: Self, previous: Self?) -> [ElementOperation] {
        debug("Calling Optional makeViews on \(Self.self) - previous? \(previous == nil ? "no" : "yes")")

        // If there is no previous node and we have a value, always insert (by giving no previous node)
        guard let previous = previous else {
            switch view {
                case .none:
                    return []
                case let .some(view):
                    return Wrapped.makeViews(view: view, previous: nil)
            }
        }

        // Otherwise check every different possibility
        switch (view, previous) {
            // Both are `.none` -> nothing has changed
            case (.none, .none):
                return []
            // Both are `.some` -> call `makeViews` recursively to have an update operation
            case let (.some(view), .some(previous)):
                return Wrapped.makeViews(view: view, previous: previous)
            // Some to none -> remove the view
            case let (.none, .some(view)):
                // Remove every view from 0 to wrapped views count
                // Each removal shifts the list to the left so remove N times
                // the element at index 0
                let toRemoveCount = Wrapped.viewsCount(view: view)
                return Array(0..<toRemoveCount).map { _ in .removal(position: 0) }
            // None to some -> call `makeViews` recursively without a previous node to have an insert operation
            case let (.some(view), .none):
                return Wrapped.makeViews(view: view, previous: nil)
        }
    }

    public static func viewsCount(view: Self) -> Int {
        switch view {
            case .none:
                return 0
            case let .some(view):
                return Wrapped.viewsCount(view: view)
        }
    }
}