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

/// A modifier takes a view and produces a new version of the view.
/// Can be used to set attributes or wrap in more views.
public protocol ViewModifier {
    /// Modifier content placeholder given to `body(content:)`.
    typealias Content = ViewModifierContent<Self>

    /// The type of this modifier's body.
    associatedtype Body: View

    /// This modifier's body.
    @ViewBuilder func body(content: Content) -> Body

    /// Creates the graph node for this modifier.
    static func make(modifier: Self, input: MakeInput) -> MakeOutput

    /// The number of static edges of this modifier.
    /// Must be constant.
    static func staticEdgesCount() -> Int
}

public extension ViewModifier {
    /// Default implementation for `make()` when there is a body: compare the modifier and call `body` if needed.
    static func make(modifier: Self, input: MakeInput) -> MakeOutput {
        // Get the previous modifier and compare it
        if let previous = input.storage?.value, anyEquals(lhs: modifier, rhs: previous) {
            return .unchanged(type: Self.self)
        }

        // The modifier changed
        let output = ElementOutput(type: Self.self, storage: modifier, implementationProxy: ImplementationProxy())

        // Re-evaluate body
        let body = modifier.body(content: ViewModifierContent())
        let bodyStorage = input.storage?.edges[0]
        let bodyInput = MakeInput(storage: bodyStorage)
        let bodyOutput = Body.make(view: body, input: bodyInput)

        return .changed(new: .init(node: output, staticEdges: [bodyOutput]))
    }

    /// Default implementation for `staticEdgesCount()` when there is a body: return one edge,
    /// the body.
    static func staticEdgesCount() -> Int {
        return 1
    }
}

public extension ViewModifier where Body == Never {
    /// Default implementation for `make()` when there is no body: return an empty unchanged node.
    static func make(modifier: Self, input: MakeInput) -> MakeOutput {
        return .changed(new: .init(node: ElementOutput(type: Self.self, storage: nil, implementationProxy: ImplementationProxy()), staticEdges: []))
    }

    /// Default implementation for `staticEdgesCount()` when there is no body.
    /// There are no edges.
    static func staticEdgesCount() -> Int {
        return 0
    }

    func body(content: Content) -> Never {
        fatalError()
    }
}

/// Placeholder for view modifier content.
public struct ViewModifierContent<Modifier>: View where Modifier: ViewModifier {
    public typealias Body = Never
    public typealias Implementation = Never

    public static func make(view: ViewModifierContent, input: MakeInput) -> MakeOutput {
        let output = ElementOutput(type: Self.self, storage: nil, implementationProxy: view.implementationProxy)
        return .changed(new: .init(node: output, staticEdges: []))
    }

    /// View modifier content has no edges.
    public static func staticEdgesCount() -> Int {
        return 0
    }
}

public extension View {
    /// Returns a modified version of the view with the given modifier applied.
    func modifier<Modifier>(_ modifier: Modifier) -> some View where Modifier: ViewModifier {
        return ModifiedContent<Modifier, Self>(modifier: modifier, content: self)
    }
}

extension ModifiedContent: View where Content: View, Modifier: ViewModifier {
    public typealias Body = Never
    public typealias Implementation = Never

    public static func make(view: ModifiedContent, input: MakeInput) -> MakeOutput {
        let output = ElementOutput(type: Self.self, storage: nil, implementationProxy: view.implementationProxy)
        let edges = [
            Modifier.make(modifier: view.modifier, input: MakeInput(storage: input.storage?.edges[0])),
            Content.make(view: view.content, input: MakeInput(storage: input.storage?.edges[1]))
        ]

        return .changed(new: .init(node: output, staticEdges: edges))
    }

    /// Modified content has two edges: the first one is the modifier and the second one
    /// is the wrapped content.
    public static func staticEdgesCount() -> Int {
        return 2
    }

    public static func makeImplementations(of view: Self) -> [ElementImplementation] {
        fatalError("Unimplemented")
    }
}
