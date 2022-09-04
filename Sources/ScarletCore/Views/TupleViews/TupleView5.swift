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

public struct TupleView5<E0, E1, E2, E3, E4>: View where E0: Element, E1: Element, E2: Element, E3: Element, E4: Element {
    public typealias Input = StaticMakeInput5<Self>
    public typealias Output = StaticMakeOutput5<Self, E0, E1, E2, E3, E4>

    let e0: E0
    let e1: E1
    let e2: E2
    let e3: E3
    let e4: E4

    public static func makeNode(
        of element: Self,
        in parent: (any ElementNode)?,
        implementationPosition: Int
    ) -> StaticElementNode5<Self, E0, E1, E2, E3, E4> where Input == StaticMakeInput5<Self> {
        return .init(making: element, in: parent, implementationPosition: implementationPosition)
    }

    public static func make(
        _ element: Self,
        input: StaticMakeInput5<Self>
    ) -> StaticMakeOutput5<Self, E0, E1, E2, E3, E4> {
        return .init(
            e0: element.e0,
            e1: element.e1,
            e2: element.e2,
            e3: element.e3,
            e4: element.e4
        )
    }
}

public extension ViewBuilder {
    static func buildBlock<C0, C1, C2, C3, C4>(_ c0: C0, _ c1: C1, _ c2: C2, _ c3: C3, _ c4: C4) -> TupleView5<C0, C1, C2, C3, C4> where C0: View, C1: View, C2: View, C3: View, C4: View {
        return .init(
            e0: c0,
            e1: c1,
            e2: c2,
            e3: c3,
            e4: c4
        )
    }
}
