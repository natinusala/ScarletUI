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

// Generated by `codegen.py` from `TupleView.gyb`

public struct TupleView2<E0, E1>: View where E0: ComponentModel, E1: ComponentModel {
    public typealias Target = Never

    public typealias Input = StaticComponentInput2<Self>
    public typealias Output = StaticComponentOutput2<Self, E0, E1>

    let e0: E0
    let e1: E1

    public static func makeNode(
        of component: Self,
        in parent: (any ComponentNode)?,
        targetPosition: Int,
        using context: Context
    ) -> StaticComponentNode2<Self, E0, E1> where Input == StaticComponentInput2<Self> {
        return .init(making: component, in: parent, targetPosition: targetPosition, using: context)
    }

    public static func make(
        _ component: Self,
        input: StaticComponentInput2<Self>
    ) -> StaticComponentOutput2<Self, E0, E1> {
        return .init(
            e0: component.e0,
            e1: component.e1
        )
    }
}

public extension ComponentBuilder {
    static func buildBlock<C0, C1>(_ c0: C0, _ c1: C1) -> TupleView2<C0, C1> where C0: View, C1: View {
        return .init(
            e0: c0,
            e1: c1
        )
    }
}
