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
    static func make(view: Self, input: MakeInput) -> MakeOutput

    /// The number of static edges of this view.
    /// Must be constant.
    static func staticEdgesCount() -> Int
}

extension View {
    /// Default implementation of `make()` when the view has a body: compare the view with the previous stored
    /// one and see if it changed. If it did, re-evaluate its `body`.
    public static func make(view: Self, input: MakeInput) -> MakeOutput {
        // Get the previous view and compare it
        if let previous = input.storage?.value, anyEquals(lhs: view, rhs: previous) {
            return .unchanged(type: Self.self)
        }

        // The view changed
        let output = ElementOutput(type: Self.self, storage: view)

        // Re-evaluate body
        let body = view.body
        let bodyStorage = input.storage?.edges[0]
        let bodyInput = MakeInput(storage: bodyStorage)
        let bodyOutput = Body.make(view: body, input: bodyInput)

        return .changed(new: .init(node: output, staticEdges: [bodyOutput]))
    }

    public static func staticEdgesCount() -> Int {
        return 1
    }
}

extension View {
    /// Default implementation of `make()` when the view has no body: return the view itself with
    /// no storage and no edges. Used for "leaves" of the view graph.
    public static func make(view: Self, input: MakeInput) -> MakeOutput where Body == Never {
        return .changed(new: .init(node: ElementOutput(type: Self.self, storage: nil), staticEdges: []))
    }

    public static func staticEdgesCount() -> Int where Body == Never {
        return 0
    }
}

extension Never: View {
    public var body: Never {
        return fatalError()
    }

    public static func make(view: Self, input: MakeInput) -> MakeOutput {}

    public static func staticEdgesCount() -> Int {
        fatalError()
    }
}

public extension View where Body == Never {
    var body: Never {
        fatalError()
    }
}
