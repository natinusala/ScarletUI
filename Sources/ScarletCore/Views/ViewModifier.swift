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
public protocol ViewModifier: Accessor, Makeable, IsPodable {
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
    static var staticEdgesCount: Int { get }
}

public extension ViewModifier {
    /// Default implementation for `make()` when there is a body: compare the modifier and call `body` if needed.
    static func make(modifier: Self?, input: MakeInput) -> MakeOutput {
        // First case: no modifier has been given, we assume it unchanged
        // but content may still have changed
        guard var modifier = modifier else {
            let bodyInput = MakeInput(storage: input.storage?.edges.asStatic[0], implementationPosition: input.implementationPosition, context: input.context)
            let bodyOutput = Body.make(view: nil, input: bodyInput)

            return Self.output(
                from: input,
                node: nil,
                staticEdges: [.some(bodyOutput)],
                implementationPosition: input.implementationPosition,
                implementationCount: bodyOutput.implementationCount,
                accessor: modifier?.accessor
            )
        }

        if !input.preserveState {
            input.storage?.setupState(on: &modifier)
        }

        // Second case: a modifier has been given
        // Compare it with the previous one to see if it changed
        // If so, re-evaluate its body. Otherwise, its content may have changed
        // so do the same as above
        if let previous = input.storage?.value, anyEquals(lhs: modifier, rhs: previous) {
            // Modifier has not changed
            let bodyInput = MakeInput(storage: input.storage?.edges.asStatic[0], implementationPosition: input.implementationPosition, context: input.context)
            let bodyOutput = Body.make(view: nil, input: bodyInput)

            return Self.output(
                from: input,
                node: nil,
                staticEdges: [.some(bodyOutput)],
                implementationPosition: input.implementationPosition,
                implementationCount: bodyOutput.implementationCount,
                accessor: modifier.accessor
            )
        } else {
            // Modifier has changed
            let output = ElementOutput(storage: modifier, attributes: modifier.collectAttributes())

            let bodyInput = MakeInput(storage: input.storage?.edges.asStatic[0], implementationPosition: input.implementationPosition, context: input.context)
            let body = Dependencies.bodyAccessor.makeBody(of: modifier, storage: bodyInput.storage)
            let bodyOutput = Body.make(view: body, input: bodyInput)

            return Self.output(
                from: input,
                node: output,
                staticEdges: [.some(bodyOutput)],
                implementationPosition: input.implementationPosition,
                implementationCount: bodyOutput.implementationCount,
                accessor: modifier.accessor
            )
        }
    }

    /// Default implementation for `staticEdgesCount()` when there is a body: return one edge,
    /// the body.
    static var staticEdgesCount: Int {
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

/// Context to make the VMC edge (the "content"), given by the associated `ModifiedContent`
/// since it owns the content to make. Stored in a stack inside ``MakeContext``.
struct ViewModifierContentContext {
    let content: (any Makeable)?
}

/// Placeholder for view modifier content.
public struct ViewModifierContent<Modifier>: View where Modifier: ViewModifier {
    public typealias Body = Never
    public typealias Implementation = Never

    public static func make(view: Self?, input: MakeInput) -> MakeOutput {
        // Make our edge: the actual modified content from the given VMC context
        let (vmcContext, contentContext) = input.context.poppingVMCContext()

        guard let content = vmcContext.content else {
            // We don't have a content node, consider ourself unchanged
            return Self.output(
                from: input,
                node: nil,
                staticEdges: nil,
                implementationPosition: input.implementationPosition,
                implementationCount: input.storage.implementationCount,
                accessor: nil
            )
        }

        // We have a content node, make it
        let contentStorage = input.storage?.edges.asStatic[0]
        let contentInput = MakeInput(
            storage: contentStorage,
            implementationPosition: input.implementationPosition,
            context: contentContext
        )

        let contentOutput = content.make(input: contentInput)

        return Self.output(
            from: input,
            node: nil,
            staticEdges: [.some(contentOutput)],
            implementationPosition: input.implementationPosition,
            implementationCount: contentOutput.implementationCount,
            accessor: view?.accessor
        )
    }

    /// View modifier content has one edge, the modified content.
    public static var staticEdgesCount: Int {
        return 1
    }
}

extension ModifiedContent: View, Accessor, Makeable, Implementable, IsPodable where Content: View, Modifier: ViewModifier {
    public typealias Body = Never
    public typealias Implementation = Never

    public static func make(view: Self?, input: MakeInput) -> MakeOutput {
        // Prepare context for our VMCs
        let vmcContext = ViewModifierContentContext(
            content: view?.content
        )

        // Make our one edge: the modifier
        let modifierStorage = input.storage?.edges.asStatic[0]
        let modifierContext = input.context.pushingVMCContext(context: vmcContext)
        let modifierInput = MakeInput(storage: modifierStorage, implementationPosition: input.implementationPosition, context: modifierContext)
        let modifierOutput = Modifier.make(modifier: view?.modifier, input: modifierInput)

        return Self.output(
            from: input,
            node: nil,
            staticEdges: [.some(modifierOutput)],
            implementationPosition: input.implementationPosition,
            implementationCount: modifierOutput.implementationCount,
            accessor: view?.accessor
        )
    }

    /// Modified content has one edge: the modifier body.
    public static var staticEdgesCount: Int {
        return 1
    }
}

public extension ViewModifier {
    func make(input: MakeInput) -> MakeOutput {
        return Self.make(modifier: self, input: input)
    }
}

public extension View {
    /// Returns a modified version of the view with the given modifier applied.
    func modifier<Modifier>(_ modifier: Modifier) -> some View where Modifier: ViewModifier {
        return ModifiedContent<Modifier, Self>(modifier: modifier, content: self)
    }
}

public extension ViewModifier where Body == Never {
    func body(content: Content) -> Body {
        fatalError()
    }
}

public extension ViewModifier {
    /// Convenience function to create a `MakeOutput` from a `ViewModifier` with less boilerplate.
    static func output(
        from input: MakeInput,
        node: ElementOutput?,
        staticEdges: [MakeOutput.StaticEdge]?,
        implementationPosition: Int,
        implementationCount: Int,
        accessor: Accessor?
    ) -> MakeOutput {
        Logger.debug(debugImplementationVerbose, "\(Self.self) output returned implementationCount: \(implementationCount)")

        return MakeOutput(
            from: input,
            nodeKind: .viewModifier,
            nodeType: Self.self,
            node: node,
            implementationPosition: implementationPosition,
            implementationCount: implementationCount,
            edges: .static(staticEdges, count: Self.staticEdgesCount),
            accessor: accessor
        )
    }
}
