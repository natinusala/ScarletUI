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
public protocol View: Accessor, Makeable, Implementable, IsPodable, ElementEdgesQueryable {
    /// The type of this view's body.
    associatedtype Body: View

    /// This view's body.
    @ViewBuilder var body: Body { get }

    /// Creates the graph node for a view.
    /// If no view is specified, assume it hasn't changed but still evaluate
    /// edges with `view: nil` recursively.
    static func make(view: Self?, input: MakeInput) -> MakeOutput
}

public extension View {
    /// Default implementation of `make()` when the view has a body: compare the view with the previous stored
    /// one and see if it changed. If it did, re-evaluate its `body`.
    static func make(view: Self?, input: MakeInput) -> MakeOutput {
        // If no view is specified, consider the view entirely unchanged,
        // including its body
        guard var view = view else {
            return Self.output(
                from: input,
                node: nil,
                staticEdges: nil,
                implementationPosition: input.implementationPosition,
                implementationCount: input.storage.implementationCount,
                accessor: nil
            )
        }

        if !input.preserveState {
            input.storage?.setupState(on: &view)
        }

        // Get the previous view and compare it
        // Return an unchanged output of it's equal
        if let previous = input.storage?.value, anyEquals(lhs: view, rhs: previous) {
            return Self.output(
                from: input,
                node: nil,
                staticEdges: nil,
                implementationPosition: input.implementationPosition,
                implementationCount: input.storage.implementationCount,
                accessor: view.accessor
            )
        }

        // The view changed
        let output = ElementOutput(storage: view, attributes: view.collectAttributes())

        // Re-evaluate body
        let body = Dependencies.bodyAccessor.makeBody(of: view, storage: input.storage)
        let bodyStorage = input.storage?.edges.staticAt(0, for: Body.self)
        let bodyInput = MakeInput(storage: bodyStorage, implementationPosition: Self.substantial ? 0 : input.implementationPosition, context: input.context)
        let bodyOutput = Body.make(view: body, input: bodyInput)

        return Self.output(
            from: input,
            node: output,
            staticEdges: [.some(bodyOutput)],
            implementationPosition: input.implementationPosition,
            implementationCount: Self.substantial ? 1 : bodyOutput.implementationCount,
            accessor: view.accessor
        )
    }

    /// Default implementation for `staticEdgesCount()` when there is a body: return one edge,
    /// the body.
    static var edgesType: ElementEdgesType{
        return .static(count: 1)
    }

    /// Creates the implementation for the view.
    static func makeImplementation(of view: Self) -> ImplementationNode? {
        if Implementation.self == Never.self {
            return nil
        }

        return Implementation(kind: .view, displayName: view.displayName)
    }

    var accessor: Accessor {
        return self
    }
}

public extension View where Body == Never {
    /// Default implementation of `make()` when the view has no body: return the view itself with
    /// no storage and no edges. Used for "leaves" of the view graph.
    static func make(view: Self?, input: MakeInput) -> MakeOutput {
        return Self.output(
            from: input,
            node: ElementOutput(storage: nil, attributes: view?.collectAttributes() ?? [:]),
            staticEdges: [],
            implementationPosition: input.implementationPosition,
            implementationCount: Self.substantial ? 1 : 0,
            accessor: view?.accessor
        )
    }

    /// Default implementation for `staticEdgesCount()` when there is no body: no edges.
    static var edgesType: ElementEdgesType{
        return .static(count: 0)
    }

    var body: Never {
        fatalError()
    }
}

public extension View {
    /// Default implementation of `updateImplementation()`: do nothing.
    static func updateImplementation(_ implementation: Implementation, with view: Self) {}

    func makeImplementation() -> ImplementationNode? {
        return Self.makeImplementation(of: self)
    }

    func updateImplementation(_ implementation: any ImplementationNode) {
        guard let implementation = implementation as? Implementation else {
            fatalError("Tried to update an implementation with a different type: got \(type(of: implementation)), expected \(Implementation.self))")
        }

        Self.updateImplementation(implementation, with: self)
    }

    func collectAttributes() -> AttributesStash {
        return self.collectAttributesUsingMirror()
    }
}

public extension View {
    /// Convenience function to create a `MakeOutput` from a `View` with less boilerplate.
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
            nodeKind: .view,
            nodeType: Self.self,
            node: node,
            implementationPosition: implementationPosition,
            implementationCount: implementationCount,
            edges: .static(staticEdges, count: Self.staticEdgesCount),
            accessor: accessor
        )
    }

    /// Convenience function to create a `MakeOutput` from a `View` with less boilerplate.
    static func output(
        from input: MakeInput,
        node: ElementOutput?,
        operations: [DynamicOperation],
        accessor: Accessor?,
        viewContent: DynamicViewContent?
    ) -> MakeOutput {
        fatalError("Dynamic output not implemented")

        // Logger.debug(debugImplementationVerbose, "\(Self.self) output returned implementationCount: \(implementationCount)")

        // return MakeOutput(
        //     from: input,
        //     nodeKind: .view,
        //     nodeType: Self.self,
        //     node: node,
        //     implementationPosition: implementationPosition,
        //     implementationCount: implementationCount,
        //     edges: .dynamic(operations: operations, viewContent: viewContent),
        //     accessor: accessor
        // )
    }

    /// Display name of the view, aka. its type stripped of any generic parameters.
    var displayName: String {
        return String(describing: Self.self).before(first: "<")
    }
}

public extension View {
    func make(input: MakeInput) -> MakeOutput {
        return Self.make(view: self, input: input)
    }
}
