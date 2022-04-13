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

/// A scene is the container for the app views, typically a desktop window.
public protocol Scene {
    /// The type of this scene's body.
    associatedtype Body: Scene

    /// This scene's body.
    var body: Body { get }

    /// Creates the graph node for a scene.
    /// If no scene is specified, assume it hasn't changed but still evaluate
    /// edges with `scene: nil` recursively.
    static func make(scene: Self?, input: MakeInput) -> MakeOutput

    /// The number of static edges of a scene.
    /// Must be constant.
    static func staticEdgesCount() -> Int

    /// The type of this scene's implementation.
    /// Set to `Never` if there is none.
    associatedtype Implementation: ImplementationNode

    /// Updates an implementation node with the given scene.
    static func updateImplementation(_ implementation: Implementation, with scene: Self)
}

public extension Scene {
    /// Default implementation of `make()`: compare the scene with the previous stored
    /// one and see if it changed. If it did, re-evaluate its `body`.
    static func make(scene: Self?, input: MakeInput) -> MakeOutput {
        // If no scene is specified, consider the scene entirely unchanged,
        // including its body
        guard let scene = scene else {
            return Self.output(node: nil, staticEdges: nil, implementationProxy: nil)
        }

        // Get the previous scene and compare it
        // Return an unchanged output of it's equal
        if let previous = input.storage?.value, anyEquals(lhs: scene, rhs: previous) {
            return Self.output(node: nil, staticEdges: nil, implementationProxy: scene.implementationProxy)
        }

        // The scene changed
        let output = ElementOutput(storage: scene)

        // Re-evaluate body
        let body = scene.body
        let bodyStorage = input.storage?.edges[0]
        let bodyInput = MakeInput(storage: bodyStorage)
        let bodyOutput = Body.make(scene: body, input: bodyInput)

        return Self.output(node: output, staticEdges: [bodyOutput], implementationProxy: scene.implementationProxy)
    }

    /// A scene has one edge: its body.
    static func staticEdgesCount() -> Int {
        return 1
    }

    /// Convenience function to create a `MakeOutput` from a `Scene` with less boilerplate.
    static func output(node: ElementOutput?, staticEdges: [MakeOutput?]?, implementationProxy: ImplementationProxy?) -> MakeOutput {
        return MakeOutput(
            nodeKind: .scene,
            nodeType: Self.self,
            node: node,
            staticEdges: staticEdges,
            staticEdgesCount: Self.staticEdgesCount(),
            implementationProxy: implementationProxy
        )
    }

    /// Creates the implementation for the scene.
    static func makeImplementation(of scene: Self) -> ImplementationNode? {
        if Implementation.self == Never.self {
            return nil
        }

        return Implementation(kind: .scene, displayName: scene.displayName)
    }

    var implementationProxy: ImplementationProxy {
        return ImplementationProxy(scene: self)
    }

    /// Display name of the scene, aka. its type stripped of any generic parameters.
    var displayName: String {
        return String(describing: Self.self).before(first: "<")
    }
}

public extension Scene {
    /// Default implementation of `updateImplementation()`: do nothing.
    static func updateImplementation(_ implementation: Implementation, with scene: Self) {}
}

extension Scene where Body == Never {
    public var body: Never {
        fatalError()
    }
}

extension Never: Scene {}
