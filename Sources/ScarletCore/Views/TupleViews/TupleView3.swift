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

public struct TupleView3<E0, E1, E2>: View where E0: ComponentModel, E1: ComponentModel, E2: ComponentModel {
    public typealias Target = Never

    public typealias Input = StaticComponentInput3<Self>
    public typealias Output = StaticComponentOutput3<Self, E0, E1, E2>

    let e0: E0
    let e1: E1
    let e2: E2

    public static func makeNode(
        of component: Self,
        in parent: (any ComponentNode)?,
        targetPosition: Int,
        using context: Context
    ) -> StaticComponentNode3<Self, E0, E1, E2> where Input == StaticComponentInput3<Self> {
        return .init(making: component, in: parent, targetPosition: targetPosition, using: context)
    }

    public static func make(
        _ component: Self,
        input: StaticComponentInput3<Self>
    ) -> StaticComponentOutput3<Self, E0, E1, E2> {
        return .init(
            e0: component.e0,
            e1: component.e1,
            e2: component.e2
        )
    }
}

public extension ComponentBuilder {
    static func buildBlock<C0, C1, C2>(_ c0: C0, _ c1: C1, _ c2: C2) -> TupleView3<C0, C1, C2> where C0: View, C1: View, C2: View {
        return .init(
            e0: c0,
            e1: c1,
            e2: c2
        )
    }
}
