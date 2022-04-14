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
public protocol View: Accessor {
    /// The type of this view's body.
    associatedtype Body: View

    /// This view's body.
    @ViewBuilder var body: Body { get }

    /// Creates the graph node for a view.
    /// If no view is specified, assume it hasn't changed but still evaluate
    /// edges with `view: nil` recursively.
    static func make(view: Self?, input: MakeInput) -> MakeOutput

    /// The number of static edges of a view.
    /// Must be constant.
    static func staticEdgesCount() -> Int

    /// The type of this view's implementation.
    /// Set to `Never` if there is none.
    associatedtype Implementation: ImplementationNode

    /// Updates an implementation node with the given view.
    static func updateImplementation(_ implementation: Implementation, with view: Self)
}

public extension View {
    /// Default implementation of `make()` when the view has a body: compare the view with the previous stored
    /// one and see if it changed. If it did, re-evaluate its `body`.
    static func make(view: Self?, input: MakeInput) -> MakeOutput {
        // If no view is specified, consider the view entirely unchanged,
        // including its body
        guard let view = view else {
            return Self.output(node: nil, staticEdges: nil, accessor: nil)
        }

        // Get the previous view and compare it
        // Return an unchanged output of it's equal
        if let previous = input.storage?.value, anyEquals(lhs: view, rhs: previous) {
            return Self.output(node: nil, staticEdges: nil, accessor: view.accessor)
        }

        // The view changed
        let output = ElementOutput(storage: view)

        // Re-evaluate body
        let body = view.body
        let bodyStorage = input.storage?.edges[0]
        let bodyInput = MakeInput(storage: bodyStorage)
        let bodyOutput = Body.make(view: body, input: bodyInput)

        return Self.output(node: output, staticEdges: [bodyOutput], accessor: view.accessor)
    }

    /// Default implementation for `staticEdgesCount()` when there is a body: return one edge,
    /// the body.
    static func staticEdgesCount() -> Int {
        return 1
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
        return Self.output(node: nil, staticEdges: [], accessor: view?.accessor)
    }

    /// Default implementation for `staticEdgesCount()` when there is no body: no edges.
    static func staticEdgesCount() -> Int {
        return 0
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

    func collectAttributes() -> [AttributeSetter] {
        return self.collectAttributesUsingMirror()
    }
}

public extension View {
    /// Convenience function to create a `MakeOutput` from a `View` with less boilerplate.
    static func output(node: ElementOutput?, staticEdges: [MakeOutput?]?, accessor: Accessor?) -> MakeOutput {
        return MakeOutput(
            nodeKind: .view,
            nodeType: Self.self,
            node: node,
            staticEdges: staticEdges,
            staticEdgesCount: Self.staticEdgesCount(),
            accessor: accessor
        )
    }

    /// Display name of the view, aka. its type stripped of any generic parameters.
    var displayName: String {
        return String(describing: Self.self).before(first: "<")
    }
}

extension Never: View {
    public typealias Implementation = Never

    public var body: Never {
        return fatalError()
    }

    public static func make(view: Self?, input: MakeInput) -> MakeOutput {
        fatalError()
    }

    public static func staticEdgesCount() -> Int {
        fatalError()
    }

    public static func updateImplementation(_ implementation: Never, with view: Never) {}

    public func makeImplementation() -> ImplementationNode? {
        fatalError()
    }

    public func updateImplementation(_ implementation: any ImplementationNode) {}

    public func collectAttributes() -> [AttributeSetter] {
        fatalError()
    }
}
