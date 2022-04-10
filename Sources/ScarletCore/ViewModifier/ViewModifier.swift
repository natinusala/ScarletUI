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
    static func make(modifier: Self?, input: MakeInput) -> MakeOutput

    /// The number of static edges of this modifier.
    /// Must be constant.
    static func staticEdgesCount() -> Int
}

public extension ViewModifier {
    /// Default implementation for `make()` when there is a body: compare the modifier and call `body` if needed.
    static func make(modifier: Self?, input: MakeInput) -> MakeOutput {
        // First case: no modifier has been given, we assume it unchanged
        // but content may still have changed
        guard let modifier = modifier else {
            let bodyInput = MakeInput(storage: input.storage?.edges[0])
            let bodyOutput = Body.make(view: nil, input: bodyInput)

            return Self.output(node: nil, staticEdges: [bodyOutput])
        }

        // Second case: a modifier has been given
        // Compare it with the previous one to see if it changed
        // If so, re-evaluate its body. Otherwise, its content may have changed
        // so do the same as above
        if let storageValue = input.storage?.value, anyEquals(lhs: storageValue, rhs: modifier) {
            // Modifier has not changed
            let bodyInput = MakeInput(storage: input.storage?.edges[0])
            let bodyOutput = Body.make(view: nil, input: bodyInput)

            return Self.output(node: nil, staticEdges: [bodyOutput])
        } else {
            // Modifier has changed
            let output = ElementOutput(storage: modifier)
            let bodyInput = MakeInput(storage: input.storage?.edges[0])
            let bodyOutput = Body.make(view: modifier.body(content: ViewModifierContent()), input: bodyInput)

            return Self.output(node: output, staticEdges: [bodyOutput])
        }
    }

    /// Default implementation for `staticEdgesCount()` when there is a body: return one edge,
    /// the body.
    static func staticEdgesCount() -> Int {
        return 1
    }
}

public extension ViewModifier where Body == Content {
    /// Body for attributes-only modifiers: return content itself, unmodified.
    func body(content: Content) -> Content {
        return content
    }
}

/// Placeholder for view modifier content.
public struct ViewModifierContent<Modifier>: View where Modifier: ViewModifier {
    public typealias Body = Never

    public static func make(view: ViewModifierContent, input: MakeInput) -> MakeOutput {
        /// Return an empty list for static edges. ModifiedContent will then go through this
        /// result and replace the empty list by the modified content node.
        return Self.output(node: nil, staticEdges: [])
    }

    /// View modifier content has one edge, the modified content.
    public static func staticEdgesCount() -> Int {
        return 1
    }
}

public extension View {
    /// Returns a modified version of the view with the given modifier applied.
    func modifier<Modifier>(_ modifier: Modifier) -> some View where Modifier: ViewModifier {
        return ModifiedContent<Modifier, Self>(modifier: modifier, content: self)
    }
}

public extension ViewModifier {
    /// Convenience function to create a `MakeOutput` from a `ViewModifier` with less boilerplate.
    static func output(node: ElementOutput?, staticEdges: [MakeOutput?]?) -> MakeOutput {
        return MakeOutput(
            nodeKind: .viewModifier,
            nodeType: Self.self,
            node: node,
            staticEdges: staticEdges,
            staticEdgesCount: Self.staticEdgesCount()
        )
    }
}

extension ModifiedContent: View where Content: View, Modifier: ViewModifier {
    public typealias Body = Never

    public static func make(view: Self?, input: MakeInput) -> MakeOutput {
        // Make our one edge: the modifier
        let modifierStorage = input.storage?.edges[0]
        let modifierInput = MakeInput(storage: modifierStorage)
        var modifierOutput = Modifier.make(modifier: view?.modifier, input: modifierInput)

        // Visit the output and find any `ViewModifierContent` - replace its empty edges list by
        // a new "content" node
        modifierOutput.transform(storage: modifierStorage) { output, storage in
            var output = output

            if output.nodeType == ViewModifierContent<Modifier>.self {
                // Content storage is storage of VMC edge 0
                let contentInput = MakeInput(storage: storage?.edges[0])
                let contentOutput = Content.make(view: view?.content, input: contentInput)

                output.staticEdges = [contentOutput]
            }

            return output
        }

        let edges = [modifierOutput]
        return Self.output(node: nil, staticEdges: edges)

    }

    /// Modified content has one edge: the modifier body.
    public static func staticEdgesCount() -> Int {
        return 1
    }
}

extension MakeOutput {
    /// Transforms the node and all of its edges using a transformation function. Storage nodes are
    /// properly resolved by following the same path between the output graph and storage graph.
    mutating func transform(storage: StorageNode?, transform: (MakeOutput, StorageNode?) -> MakeOutput) {
        self = transform(self, storage)

        for i in 0..<self.staticEdgesCount {
            self.staticEdges?[i]?.transform(storage: storage?.edges[i], transform: transform)
        }
    }
}