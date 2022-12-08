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

/// A view that applies 9 attributes to its content in an efficient way.
/// Behaves similarly to a view modifier by wrapping its content.
/// Use with ``View.attributed(_:)`` like you would use ``View.modified(by:)`` for view modifiers.
public struct ViewAttribute9<Content: View, A0: AttributeSetter, A1: AttributeSetter, A2: AttributeSetter, A3: AttributeSetter, A4: AttributeSetter, A5: AttributeSetter, A6: AttributeSetter, A7: AttributeSetter, A8: AttributeSetter>: View {
    public typealias Input = StaticMakeInput1<Self>
    public typealias Output = StaticMakeOutput1<Self, Content>
    public typealias Implementation = Never

    let content: Content

    let a0: A0
    let a1: A1
    let a2: A2
    let a3: A3
    let a4: A4
    let a5: A5
    let a6: A6
    let a7: A7
    let a8: A8

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
                element.a4.target: element.a4,
                element.a5.target: element.a5,
                element.a6.target: element.a6,
                element.a7.target: element.a7,
                element.a8.target: element.a8,
            ],
            source: source
        )
    }

    public static func makeNode(
        of element: Self,
        in parent: (any ElementNode)?,
        implementationPosition: Int,
        using context: Context
    ) -> StaticElementNode1<Self, Content> where Input == StaticMakeInput1<Self> {
        return .init(making: element, in: parent, implementationPosition: implementationPosition, using: context)
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
    func attributed<A0: AttributeSetter, A1: AttributeSetter, A2: AttributeSetter, A3: AttributeSetter, A4: AttributeSetter, A5: AttributeSetter, A6: AttributeSetter, A7: AttributeSetter, A8: AttributeSetter>(_ a0: A0, _ a1: A1, _ a2: A2, _ a3: A3, _ a4: A4, _ a5: A5, _ a6: A6, _ a7: A7, _ a8: A8) -> ViewAttribute9<Self, A0, A1, A2, A3, A4, A5, A6, A7, A8> {
        return ViewAttribute9<Self, A0, A1, A2, A3, A4, A5, A6, A7, A8>(content: self, a0: a0, a1: a1, a2: a2, a3: a3, a4: a4, a5: a5, a6: a6, a7: a7, a8: a8)
    }
}
