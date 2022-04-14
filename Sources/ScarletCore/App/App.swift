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

/// A ScarletUI application.
/// An app is made of one scene, and a scene is made of one or multiple
/// views.
public protocol App: ImplementationAccessor {
    /// Initializer used for the framework to create the app on boot.
    init()

    /// The type of this app's body.
    associatedtype Body: Scene

    /// This app's body.
    var body: Body { get }

    /// Creates the graph node for an app.
    /// If no app is specified, assume it hasn't changed but still evaluate
    /// edges with `app: nil` recursively.
    static func make(app: Self?, input: MakeInput) -> MakeOutput

    /// The number of static edges of an app.
    /// Must be constant.
    static func staticEdgesCount() -> Int

    /// The type of this app's implementation.
    /// Set to `Never` if there is none.
    associatedtype Implementation: ImplementationNode

    /// Updates an implementation node with the given app.
    static func updateImplementation(_ implementation: Implementation, with app: Self)
}

public extension App {
    /// Default implementation of `make()`: compare the app with the previous stored
    /// one and see if it changed. If it did, re-evaluate its `body`.
    static func make(app: Self?, input: MakeInput) -> MakeOutput {
        // If no app is specified, consider the app entirely unchanged,
        // including its body
        guard let app = app else {
            return Self.output(node: nil, staticEdges: nil, implementationAccessor: nil)
        }

        // Get the previous app and compare it
        // Return an unchanged output of it's equal
        if let previous = input.storage?.value, anyEquals(lhs: app, rhs: previous) {
            return Self.output(node: nil, staticEdges: nil, implementationAccessor: app.implementationAccessor)
        }

        // The app changed
        let output = ElementOutput(storage: app)

        // Re-evaluate body
        let body = app.body
        let bodyStorage = input.storage?.edges[0]
        let bodyInput = MakeInput(storage: bodyStorage)
        let bodyOutput = Body.make(scene: body, input: bodyInput)

        return Self.output(node: output, staticEdges: [bodyOutput], implementationAccessor: app.implementationAccessor)
    }

    /// An app has one edge: its body.
    static func staticEdgesCount() -> Int {
        return 1
    }

    /// Convenience function to create a `MakeOutput` from an `App` with less boilerplate.
    static func output(node: ElementOutput?, staticEdges: [MakeOutput?]?, implementationAccessor: ImplementationAccessor?) -> MakeOutput {
        return MakeOutput(
            nodeKind: .app,
            nodeType: Self.self,
            node: node,
            staticEdges: staticEdges,
            staticEdgesCount: Self.staticEdgesCount(),
            implementationAccessor: implementationAccessor
        )
    }

    /// Creates the implementation for the app.
    static func makeImplementation(of app: Self) -> ImplementationNode? {
        if Implementation.self == Never.self {
            return nil
        }

        return Implementation(kind: .app, displayName: app.displayName)
    }

    var implementationAccessor: ImplementationAccessor {
        return self
    }

    /// Display name of the app, aka. its type stripped of any generic parameters.
    var displayName: String {
        return String(describing: Self.self).before(first: "<")
    }

    /// Default `updateImplementation()` implementation: don't do anything.
    static func updateImplementation(_ implementation: Implementation, with app: Self) {}

    func make() -> ImplementationNode? {
        return Self.makeImplementation(of: self)
    }

    func update(_ implementation: any ImplementationNode) {
        guard let implementation = implementation as? Implementation else {
            fatalError("Tried to update an implementation with a different type: got \(type(of: implementation)), expected \(Implementation.self))")
        }

        Self.updateImplementation(implementation, with: self)
    }
}
