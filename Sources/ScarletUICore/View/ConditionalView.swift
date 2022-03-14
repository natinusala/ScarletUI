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

/// A conditional view that is either the "first one" or the "second one".
public struct ConditionalView<FirstContent, SecondContent>: View where FirstContent: View, SecondContent: View {
    /// Storage for the actual view.
    public enum Storage {
        case first(FirstContent)
        case second(SecondContent)
    }

    public typealias Body = Never

    let storage: Storage

    public static func makeViews(view: Self, previous: Self?) -> [ElementOperation] {
        // If there is no previous node, always insert (by giving no previous node)
        guard let previous = previous else {
            switch view.storage {
                case let .first(view):
                    return FirstContent.makeViews(view: view, previous: nil)
                case let .second(view):
                    return SecondContent.makeViews(view: view, previous: nil)
            }
        }

        // Otherwise check for every possibility
        switch (view.storage, previous.storage) {
            case let (.first(view), .first(previous)):
                return FirstContent.makeViews(view: view, previous: previous)
            case let (.second(view), .second(previous)):
                return SecondContent.makeViews(view: view, previous: previous)
            case let (.first, .second(previous)):
                return Self.replace(count: SecondContent.viewsCount(view: previous), newView: view.storage)
            case let (.second, .first(previous)):
                return Self.replace(count: FirstContent.viewsCount(view: previous), newView: view.storage)
        }
    }

    /// Returns view operations making a replacement of every view with the given new view.
    private static func replace(count: Int, newView: Storage) -> [ElementOperation] {
        var operations = [ElementOperation]()

        // Remove every view
        // As every removal shifts the list to the left, we need to remove N times
        // the 1st element
        operations = Array(0..<count).map { _ in .removal(position: 0) }

        // Make insertion operations by calling `makeViews` on the new view without
        // giving a previous one
        let insertions: [ElementOperation]
        switch newView {
            case let .first(view):
                insertions = FirstContent.makeViews(view: view, previous: nil)
            case let .second(view):
                insertions = SecondContent.makeViews(view: view, previous: nil)
        }

        operations.append(contentsOf: insertions)

        return operations
    }

    public static func viewsCount(view: Self) -> Int {
        switch view.storage {
            case let .first(view):
                return FirstContent.viewsCount(view: view)
            case let .second(view):
                return SecondContent.viewsCount(view: view)
        }
    }

    public static func equals(lhs: Self, rhs: Self) -> Bool {
        switch (lhs.storage, rhs.storage) {
            case (.first, .second), (.second, .first):
                return false
            case let (.first(lhs), .first(rhs)):
                return FirstContent.equals(lhs: lhs, rhs: rhs)
            case let (.second(lhs), .second(rhs)):
                return SecondContent.equals(lhs: lhs, rhs: rhs)
        }
    }
}
