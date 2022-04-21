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
public protocol ViewModifier: Accessor {
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

            return Self.output(node: nil, staticEdges: [bodyOutput], accessor: modifier?.accessor)
        }

        // Second case: a modifier has been given
        // Compare it with the previous one to see if it changed
        // If so, re-evaluate its body. Otherwise, its content may have changed
        // so do the same as above
        if let storageValue = input.storage?.value, anyEquals(lhs: storageValue, rhs: modifier) {
            // Modifier has not changed
            let bodyInput = MakeInput(storage: input.storage?.edges[0])
            let bodyOutput = Body.make(view: nil, input: bodyInput)

            return Self.output(node: nil, staticEdges: [bodyOutput], accessor: modifier.accessor)
        } else {
            // Modifier has changed
            let output = ElementOutput(storage: modifier, attributes: modifier.collectAttributes())

            let bodyInput = MakeInput(storage: input.storage?.edges[0])
            let bodyOutput = Body.make(view: modifier.body(content: ViewModifierContent()), input: bodyInput)

            return Self.output(node: output, staticEdges: [bodyOutput], accessor: modifier.accessor)
        }
    }

    /// Default implementation for `staticEdgesCount()` when there is a body: return one edge,
    /// the body.
    static func staticEdgesCount() -> Int {
        return 1
    }

    var accessor: Accessor {
        return self
    }

    func makeImplementation() -> ImplementationNode? {
        return nil // modifiers never have an implementation
    }

    func updateImplementation(_ implementation: any ImplementationNode) {}

    func collectAttributes() -> AttributesStash {
        return self.collectAttributesUsingMirror()
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
    public typealias Implementation = Never

    public static func make(view: ViewModifierContent, input: MakeInput) -> MakeOutput {
        /// Return an empty list for static edges. ModifiedContent will then go through this
        /// result and replace the empty list by the modified content node.
        return Self.output(node: nil, staticEdges: [], accessor: nil)
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
    static func output(node: ElementOutput?, staticEdges: [MakeOutput?]?, accessor: Accessor?) -> MakeOutput {
        return MakeOutput(
            nodeKind: .viewModifier,
            nodeType: Self.self,
            node: node,
            staticEdges: staticEdges,
            staticEdgesCount: Self.staticEdgesCount(),
            accessor: accessor
        )
    }
}

extension ModifiedContent: View, Accessor where Content: View, Modifier: ViewModifier {
    public typealias Body = Never
    public typealias Implementation = Never

    public static func make(view: Self?, input: MakeInput) -> MakeOutput {
        // Make our one edge: the modifier
        let modifierStorage = input.storage?.edges[0]
        let modifierInput = MakeInput(storage: modifierStorage)
        var modifierOutput = Modifier.make(modifier: view?.modifier, input: modifierInput)

        // Visit the output and find any `ViewModifierContent` - replace its empty edges list by
        // a new "content" node
        modifierOutput = modifierOutput.transform(storage: modifierStorage, predicate: { $0.nodeType == ViewModifierContent<Modifier>.self }) { output, storage in
            var output = output

            // Content storage is storage of VMC edge 0
            let contentInput = MakeInput(storage: storage?.edges[0])
            let contentOutput = Content.make(view: view?.content, input: contentInput)

            output.staticEdges = [contentOutput]

            return output
        }

        let edges = [modifierOutput]
        return Self.output(node: nil, staticEdges: edges, accessor: view?.accessor)
    }

    /// Modified content has one edge: the modifier body.
    public static func staticEdgesCount() -> Int {
        return 1
    }
}

extension MakeOutput {
    /// Runs the predicate on every node down the graph. If it ever returns `true`, runs the transformation function and returns the resulting
    /// output node, stopping the recursion there.
    /// Storage nodes are visited the same way as output nodes to give every output node its storage node.
    func transform(
        storage: StorageNode?,
        predicate: (MakeOutput) -> Bool,
        transform function: (MakeOutput, StorageNode?) -> MakeOutput
    ) -> MakeOutput {
        if predicate(self) {
            return function(self, storage)
        }

        var output = self
        output.staticEdges = output.staticEdges?.enumerated().map { idx, edge in
            return edge?.transform(storage: storage?.edges[idx], predicate: predicate, transform: function)
        }

        return output
    }
}
