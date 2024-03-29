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

// Generated by `codegen.py` from `ViewAttribute.gyb`

/// A view that applies 1 attributes to its content in an efficient way.
/// Behaves similarly to a view modifier by wrapping its content.
/// Use with ``View/attributed(_:)`` like you would use ``View/modified(by:)`` for view modifiers.
public struct ViewAttribute1<Content: View, A0: AttributeSetter>: View {
    public typealias Input = StaticComponentInput1<Self>
    public typealias Output = StaticComponentOutput1<Self, Content>
    public typealias Target = Never

    let content: Content

    let a0: A0

    public var body: Never {
        fatalError()
    }

    public static func collectAttributes(of component: Self, source: AnyHashable) -> AttributesStash {
        return AttributesStash(
            from: [
                component.a0.target: component.a0,
            ],
            source: source
        )
    }

    public static func makeNode(
        of component: Self,
        in parent: (any ComponentNode)?,
        targetPosition: Int,
        using context: Context
    ) -> StaticComponentNode1<Self, Content> where Input == StaticComponentInput1<Self> {
        return .init(making: component, in: parent, targetPosition: targetPosition, using: context)
    }

    public static func make(
        _ component: Self,
        input: StaticComponentInput1<Self>
    ) -> StaticComponentOutput1<Self, Content> {
        return .init(
            e0: component.content
        )
    }
}

public extension View {
    /// Returns a version of that view with the given attribute set.
    func attributed<A0: AttributeSetter>(_ a0: A0) -> ViewAttribute1<Self, A0> {
        return ViewAttribute1<Self, A0>(content: self, a0: a0)
    }
}
