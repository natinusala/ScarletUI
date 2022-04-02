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
public protocol View {
    /// The type of this view's body.
    associatedtype Body: View

    /// This view's body.
    @ViewBuilder var body: Body { get }

    /// Creates the graph node for this view.
    static func makeView(view: Self) -> ElementOutput

    /// Returns this view's children.
    static func makeChildren(view: Self) -> ElementChildren

    /// The number of static children of this view.
    /// Must be constant.
    static var staticChildrenCount: Int { get }
}

public extension View where Body == Never {
    /// Default implementation of `makeView` when `Body` is `Never`: create a node
    /// without storage.
    static func makeView(view: Self) -> ElementOutput {
        return ElementOutput(
            element: AnyElement(view: view),
            stored: false
        )
    }

    /// Default implementation of `makeChildren` when `Body` is `Never`: returns an empty list.
    /// Useful for "leaf" views that have no children.
    static func makeChildren(view: Self) -> ElementChildren {
        return ElementChildren(staticChildren: [])
    }

    /// Default value for `staticChildrenCount` when `Body` is `Never`: 0, the view has no children.
    static var staticChildrenCount: Int {
        return 0
    }
}

public extension View {
    /// Default implementation of `makeView`: creates a graph node with storage.
    static func makeView(view: Self) -> ElementOutput {
        return ElementOutput(
            element: AnyElement(view: view),
            stored: true
        )
    }

    /// Default implementation of `makeChildren`: returns the view `body` directly.
    static func makeChildren(view: Self) -> ElementChildren {
        return ElementChildren(staticChildren: [AnyElement(view: view.body)])
    }

    /// Default value for `staticChildrenCount`: 1, the view has one child, its body.
    static var staticChildrenCount: Int {
        return 1
    }
}

extension Never: View {
    public var body: Never {
        return fatalError()
    }

    public static var staticChildrenCount: Int {
        return 0
    }
}

public extension View where Body == Never {
    var body: Never {
        fatalError()
    }
}
