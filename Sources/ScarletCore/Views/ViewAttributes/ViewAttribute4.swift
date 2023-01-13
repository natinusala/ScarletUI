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

/// A view that applies 4 attributes to its content in an efficient way.
/// Behaves similarly to a view modifier by wrapping its content.
/// Use with ``View/attributed(_:)`` like you would use ``View/modified(by:)`` for view modifiers.
public struct ViewAttribute4<Content: View, A0: AttributeSetter, A1: AttributeSetter, A2: AttributeSetter, A3: AttributeSetter>: View {
    public typealias Input = StaticMakeInput1<Self>
    public typealias Output = StaticMakeOutput1<Self, Content>
    public typealias Target = Never

    let content: Content

    let a0: A0
    let a1: A1
    let a2: A2
    let a3: A3

    public var body: Never {
        fatalError()
    }

    public static func collectAttributes(of element: Self, source: AnyHashable) -> AttributesStash {
        return AttributesStash(
            from: [
                element.a0.target: element.a0,
                element.a1.target: element.a1,
                element.a2.target: element.a2,
                element.a3.target: element.a3,
            ],
            source: source
        )
    }

    public static func makeNode(
        of element: Self,
        in parent: (any ElementNode)?,
        targetPosition: Int,
        using context: Context
    ) -> StaticElementNode1<Self, Content> where Input == StaticMakeInput1<Self> {
        return .init(making: element, in: parent, targetPosition: targetPosition, using: context)
    }

    public static func make(
        _ element: Self,
        input: StaticMakeInput1<Self>
    ) -> StaticMakeOutput1<Self, Content> {
        return .init(
            e0: element.content
        )
    }
}

public extension View {
    /// Returns a version of that view with the given attribute set.
    func attributed<A0: AttributeSetter, A1: AttributeSetter, A2: AttributeSetter, A3: AttributeSetter>(_ a0: A0, _ a1: A1, _ a2: A2, _ a3: A3) -> ViewAttribute4<Self, A0, A1, A2, A3> {
        return ViewAttribute4<Self, A0, A1, A2, A3>(content: self, a0: a0, a1: a1, a2: a2, a3: a3)
    }
}
