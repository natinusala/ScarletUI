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

public struct TupleView7<E0, E1, E2, E3, E4, E5, E6>: View where E0: ComponentModel, E1: ComponentModel, E2: ComponentModel, E3: ComponentModel, E4: ComponentModel, E5: ComponentModel, E6: ComponentModel {
    public typealias Target = Never

    public typealias Input = StaticComponentInput7<Self>
    public typealias Output = StaticComponentOutput7<Self, E0, E1, E2, E3, E4, E5, E6>

    let e0: E0
    let e1: E1
    let e2: E2
    let e3: E3
    let e4: E4
    let e5: E5
    let e6: E6

    public static func makeNode(
        of component: Self,
        in parent: (any ComponentNode)?,
        targetPosition: Int,
        using context: Context
    ) -> StaticComponentNode7<Self, E0, E1, E2, E3, E4, E5, E6> where Input == StaticComponentInput7<Self> {
        return .init(making: component, in: parent, targetPosition: targetPosition, using: context)
    }

    public static func make(
        _ component: Self,
        input: StaticComponentInput7<Self>
    ) -> StaticComponentOutput7<Self, E0, E1, E2, E3, E4, E5, E6> {
        return .init(
            e0: component.e0,
            e1: component.e1,
            e2: component.e2,
            e3: component.e3,
            e4: component.e4,
            e5: component.e5,
            e6: component.e6
        )
    }
}

public extension ComponentBuilder {
    static func buildBlock<C0, C1, C2, C3, C4, C5, C6>(_ c0: C0, _ c1: C1, _ c2: C2, _ c3: C3, _ c4: C4, _ c5: C5, _ c6: C6) -> TupleView7<C0, C1, C2, C3, C4, C5, C6> where C0: View, C1: View, C2: View, C3: View, C4: View, C5: View, C6: View {
        return .init(
            e0: c0,
            e1: c1,
            e2: c2,
            e3: c3,
            e4: c4,
            e5: c5,
            e6: c6
        )
    }
}
