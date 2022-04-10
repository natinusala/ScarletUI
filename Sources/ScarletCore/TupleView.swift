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

// TODO: use a visitor pattern to merge all structs into one

public struct TupleView2<C0, C1>: View where C0: View, C1: View {
    public typealias Body = Never

    let c0: C0
    let c1: C1

    init(_ c0: C0, _ c1: C1) {
        self.c0 = c0
        self.c1 = c1
    }

    public static func make(view: Self?, input: MakeInput) -> MakeOutput {
        let edges = [
            C0.make(view: view?.c0, input: MakeInput(storage: input.storage?.edges[0])),
            C1.make(view: view?.c1, input: MakeInput(storage: input.storage?.edges[1])),
        ]

        return Self.output(node: nil, staticEdges: edges)
    }

    public static func staticEdgesCount() -> Int {
        return 2
    }
}

public struct TupleView3<C0, C1, C2>: View where C0: View, C1: View, C2: View {
    public typealias Body = Never

    let c0: C0
    let c1: C1
    let c2: C2

    init(_ c0: C0, _ c1: C1, _ c2: C2) {
        self.c0 = c0
        self.c1 = c1
        self.c2 = c2
    }

    public static func make(view: Self?, input: MakeInput) -> MakeOutput {
        let edges = [
            C0.make(view: view?.c0, input: MakeInput(storage: input.storage?.edges[0])),
            C1.make(view: view?.c1, input: MakeInput(storage: input.storage?.edges[1])),
            C2.make(view: view?.c2, input: MakeInput(storage: input.storage?.edges[2])),
        ]

        return Self.output(node: nil, staticEdges: edges)
    }

    public static func staticEdgesCount() -> Int {
        return 3
    }
}

public struct TupleView4<C0, C1, C2, C3>: View where C0: View, C1: View, C2: View, C3: View {
    public typealias Body = Never

    let c0: C0
    let c1: C1
    let c2: C2
    let c3: C3

    init(_ c0: C0, _ c1: C1, _ c2: C2, _ c3: C3) {
        self.c0 = c0
        self.c1 = c1
        self.c2 = c2
        self.c3 = c3
    }

    public static func make(view: Self?, input: MakeInput) -> MakeOutput {
        let edges = [
            C0.make(view: view?.c0, input: MakeInput(storage: input.storage?.edges[0])),
            C1.make(view: view?.c1, input: MakeInput(storage: input.storage?.edges[1])),
            C2.make(view: view?.c2, input: MakeInput(storage: input.storage?.edges[2])),
            C3.make(view: view?.c3, input: MakeInput(storage: input.storage?.edges[3])),
        ]

        return Self.output(node: nil, staticEdges: edges)
    }

    public static func staticEdgesCount() -> Int {
        return 4
    }
}

public struct TupleView5<C0, C1, C2, C3, C4>: View where C0: View, C1: View, C2: View, C3: View, C4: View {
    public typealias Body = Never

    let c0: C0
    let c1: C1
    let c2: C2
    let c3: C3
    let c4: C4

    init(_ c0: C0, _ c1: C1, _ c2: C2, _ c3: C3, _ c4: C4) {
        self.c0 = c0
        self.c1 = c1
        self.c2 = c2
        self.c3 = c3
        self.c4 = c4
    }

    public static func make(view: Self?, input: MakeInput) -> MakeOutput {
        let edges = [
            C0.make(view: view?.c0, input: MakeInput(storage: input.storage?.edges[0])),
            C1.make(view: view?.c1, input: MakeInput(storage: input.storage?.edges[1])),
            C2.make(view: view?.c2, input: MakeInput(storage: input.storage?.edges[2])),
            C3.make(view: view?.c3, input: MakeInput(storage: input.storage?.edges[3])),
            C4.make(view: view?.c4, input: MakeInput(storage: input.storage?.edges[4])),
        ]

        return Self.output(node: nil, staticEdges: edges)
    }

    public static func staticEdgesCount() -> Int {
        return 5
    }
}

public struct TupleView6<C0, C1, C2, C3, C4, C5>: View where C0: View, C1: View, C2: View, C3: View, C4: View, C5: View {
    public typealias Body = Never

    let c0: C0
    let c1: C1
    let c2: C2
    let c3: C3
    let c4: C4
    let c5: C5

    init(_ c0: C0, _ c1: C1, _ c2: C2, _ c3: C3, _ c4: C4, _ c5: C5) {
        self.c0 = c0
        self.c1 = c1
        self.c2 = c2
        self.c3 = c3
        self.c4 = c4
        self.c5 = c5
    }

    public static func make(view: Self?, input: MakeInput) -> MakeOutput {
        let edges = [
            C0.make(view: view?.c0, input: MakeInput(storage: input.storage?.edges[0])),
            C1.make(view: view?.c1, input: MakeInput(storage: input.storage?.edges[1])),
            C2.make(view: view?.c2, input: MakeInput(storage: input.storage?.edges[2])),
            C3.make(view: view?.c3, input: MakeInput(storage: input.storage?.edges[3])),
            C4.make(view: view?.c4, input: MakeInput(storage: input.storage?.edges[4])),
            C5.make(view: view?.c5, input: MakeInput(storage: input.storage?.edges[5])),
        ]

        return Self.output(node: nil, staticEdges: edges)
    }

    public static func staticEdgesCount() -> Int {
        return 6
    }
}

public extension ViewBuilder {
    static func buildBlock<C0: View, C1: View>(_ c0: C0, _ c1: C1) -> TupleView2<C0, C1> {
        return TupleView2(c0, c1)
    }

    static func buildBlock<C0: View, C1: View, C2: View>(_ c0: C0, _ c1: C1, _ c2: C2) -> TupleView3<C0, C1, C2> {
        return TupleView3(c0, c1, c2)
    }

    static func buildBlock<C0: View, C1: View, C2: View, C3: View>(_ c0: C0, _ c1: C1, _ c2: C2, _ c3: C3) -> TupleView4<C0, C1, C2, C3> {
        return TupleView4(c0, c1, c2, c3)
    }

    static func buildBlock<C0: View, C1: View, C2: View, C3: View, C4: View>(_ c0: C0, _ c1: C1, _ c2: C2, _ c3: C3, _ c4: C4) -> TupleView5<C0, C1, C2, C3, C4> {
        return TupleView5(c0, c1, c2, c3, c4)
    }

    static func buildBlock<C0: View, C1: View, C2: View, C3: View, C4: View, C5: View>(_ c0: C0, _ c1: C1, _ c2: C2, _ c3: C3, _ c4: C4, _ c5: C5) -> TupleView6<C0, C1, C2, C3, C4, C5> {
        return TupleView6(c0, c1, c2, c3, c4, c5)
    }

    // static func buildBlock<C0: View, C1: View, C2: View, C3: View, C4: View, C5: View, C6: View>(_ c0: C0, _ c1: C1, _ c2: C2, _ c3: C3, _ c4: C4, _ c5: C5, _ c6: C6) -> TupleView7<C0, C1, C2, C3, C4, C5, C6> {
    //     return TupleView7(c0, c1, c2, c3, c4, c5, c6)
    // }

    // static func buildBlock<C0: View, C1: View, C2: View, C3: View, C4: View, C5: View, C6: View, C7: View>(_ c0: C0, _ c1: C1, _ c2: C2, _ c3: C3, _ c4: C4, _ c5: C5, _ c6: C6, _ c7: C7) -> TupleView8<C0, C1, C2, C3, C4, C5, C6, C7> {
    //     return TupleView8(c0, c1, c2, c3, c4, c5, c6, c7)
    // }

    // static func buildBlock<C0: View, C1: View, C2: View, C3: View, C4: View, C5: View, C6: View, C7: View, C8: View>(_ c0: C0, _ c1: C1, _ c2: C2, _ c3: C3, _ c4: C4, _ c5: C5, _ c6: C6, _ c7: C7, _ c8: C8) -> TupleView9<C0, C1, C2, C3, C4, C5, C6, C7, C8> {
    //     return TupleView9(c0, c1, c2, c3, c4, c5, c6, c7, c8)
    // }
}
