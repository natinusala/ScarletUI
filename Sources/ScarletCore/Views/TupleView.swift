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

public struct TupleView2<C0, C1>: View where C0: View, C1: View {
    public typealias Body = Never
    public typealias Implementation = Never

    let c0: C0
    let c1: C1

    init(_ c0: C0, _ c1: C1) {
        self.c0 = c0
        self.c1 = c1
    }

    public static func make(view: Self?, input: MakeInput) -> MakeOutput {
        var implementationCount = 0
        var edges: [MakeOutput] = []

        let c0Input = MakeInput(storage: input.storage?.edges.asStatic[0], implementationPosition: input.implementationPosition + implementationCount)
        let c0Output = C0.make(view: view?.c0, input: c0Input)
        edges.append(c0Output)
        implementationCount += c0Output.implementationCount


        let c1Input = MakeInput(storage: input.storage?.edges.asStatic[1], implementationPosition: input.implementationPosition + implementationCount)
        let c1Output = C1.make(view: view?.c1, input: c1Input)
        edges.append(c1Output)
        implementationCount += c1Output.implementationCount

        return Self.output(
            node: nil,
            staticEdges: edges,
            implementationPosition: input.implementationPosition,
            implementationCount: implementationCount,
            accessor: view?.accessor
        )
    }

    public static var staticEdgesCount: Int {
        return 2
    }
}

public struct TupleView3<C0, C1, C2>: View where C0: View, C1: View, C2: View {
    public typealias Body = Never
    public typealias Implementation = Never

    let c0: C0
    let c1: C1
    let c2: C2

    init(_ c0: C0, _ c1: C1, _ c2: C2) {
        self.c0 = c0
        self.c1 = c1
        self.c2 = c2
    }

    public static func make(view: Self?, input: MakeInput) -> MakeOutput {
        var implementationCount = 0
        var edges: [MakeOutput] = []

        let c0Input = MakeInput(storage: input.storage?.edges.asStatic[0], implementationPosition: input.implementationPosition + implementationCount)
        let c0Output = C0.make(view: view?.c0, input: c0Input)
        edges.append(c0Output)
        implementationCount += c0Output.implementationCount

        let c1Input = MakeInput(storage: input.storage?.edges.asStatic[1], implementationPosition: input.implementationPosition + implementationCount)
        let c1Output = C1.make(view: view?.c1, input: c1Input)
        edges.append(c1Output)
        implementationCount += c1Output.implementationCount

        let c2Input = MakeInput(storage: input.storage?.edges.asStatic[2], implementationPosition: input.implementationPosition + implementationCount)
        let c2Output = C2.make(view: view?.c2, input: c2Input)
        edges.append(c2Output)
        implementationCount += c2Output.implementationCount

        return Self.output(
            node: nil,
            staticEdges: edges,
            implementationPosition: input.implementationPosition,
            implementationCount: implementationCount,
            accessor: view?.accessor
        )
    }

    public static var staticEdgesCount: Int {
        return 3
    }
}

public struct TupleView4<C0, C1, C2, C3>: View where C0: View, C1: View, C2: View, C3: View {
    public typealias Body = Never
    public typealias Implementation = Never

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
        var implementationCount = 0
        var edges: [MakeOutput] = []

        let c0Input = MakeInput(storage: input.storage?.edges.asStatic[0], implementationPosition: input.implementationPosition + implementationCount)
        let c0Output = C0.make(view: view?.c0, input: c0Input)
        edges.append(c0Output)
        implementationCount += c0Output.implementationCount

        let c1Input = MakeInput(storage: input.storage?.edges.asStatic[1], implementationPosition: input.implementationPosition + implementationCount)
        let c1Output = C1.make(view: view?.c1, input: c1Input)
        edges.append(c1Output)
        implementationCount += c1Output.implementationCount

        let c2Input = MakeInput(storage: input.storage?.edges.asStatic[2], implementationPosition: input.implementationPosition + implementationCount)
        let c2Output = C2.make(view: view?.c2, input: c2Input)
        edges.append(c2Output)
        implementationCount += c2Output.implementationCount

        let c3Input = MakeInput(storage: input.storage?.edges.asStatic[3], implementationPosition: input.implementationPosition + implementationCount)
        let c3Output = C3.make(view: view?.c3, input: c3Input)
        edges.append(c3Output)
        implementationCount += c3Output.implementationCount

        return Self.output(
            node: nil,
            staticEdges: edges,
            implementationPosition: input.implementationPosition,
            implementationCount: implementationCount,
            accessor: view?.accessor
        )
    }

    public static var staticEdgesCount: Int {
        return 4
    }
}

public struct TupleView5<C0, C1, C2, C3, C4>: View where C0: View, C1: View, C2: View, C3: View, C4: View {
    public typealias Body = Never
    public typealias Implementation = Never

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
        var implementationCount = 0
        var edges: [MakeOutput] = []

        let c0Input = MakeInput(storage: input.storage?.edges.asStatic[0], implementationPosition: input.implementationPosition + implementationCount)
        let c0Output = C0.make(view: view?.c0, input: c0Input)
        edges.append(c0Output)
        implementationCount += c0Output.implementationCount

        let c1Input = MakeInput(storage: input.storage?.edges.asStatic[1], implementationPosition: input.implementationPosition + implementationCount)
        let c1Output = C1.make(view: view?.c1, input: c1Input)
        edges.append(c1Output)
        implementationCount += c1Output.implementationCount

        let c2Input = MakeInput(storage: input.storage?.edges.asStatic[2], implementationPosition: input.implementationPosition + implementationCount)
        let c2Output = C2.make(view: view?.c2, input: c2Input)
        edges.append(c2Output)
        implementationCount += c2Output.implementationCount

        let c3Input = MakeInput(storage: input.storage?.edges.asStatic[3], implementationPosition: input.implementationPosition + implementationCount)
        let c3Output = C3.make(view: view?.c3, input: c3Input)
        edges.append(c3Output)
        implementationCount += c3Output.implementationCount

        let c4Input = MakeInput(storage: input.storage?.edges.asStatic[4], implementationPosition: input.implementationPosition + implementationCount)
        let c4Output = C4.make(view: view?.c4, input: c4Input)
        edges.append(c4Output)
        implementationCount += c4Output.implementationCount

        return Self.output(
            node: nil,
            staticEdges: edges,
            implementationPosition: input.implementationPosition,
            implementationCount: implementationCount,
            accessor: view?.accessor
        )
    }

    public static var staticEdgesCount: Int {
        return 5
    }
}

public struct TupleView6<C0, C1, C2, C3, C4, C5>: View where C0: View, C1: View, C2: View, C3: View, C4: View, C5: View {
    public typealias Body = Never
    public typealias Implementation = Never

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
        var implementationCount = 0
        var edges: [MakeOutput] = []

        let c0Input = MakeInput(storage: input.storage?.edges.asStatic[0], implementationPosition: input.implementationPosition + implementationCount)
        let c0Output = C0.make(view: view?.c0, input: c0Input)
        edges.append(c0Output)
        implementationCount += c0Output.implementationCount

        let c1Input = MakeInput(storage: input.storage?.edges.asStatic[1], implementationPosition: input.implementationPosition + implementationCount)
        let c1Output = C1.make(view: view?.c1, input: c1Input)
        edges.append(c1Output)
        implementationCount += c1Output.implementationCount

        let c2Input = MakeInput(storage: input.storage?.edges.asStatic[2], implementationPosition: input.implementationPosition + implementationCount)
        let c2Output = C2.make(view: view?.c2, input: c2Input)
        edges.append(c2Output)
        implementationCount += c2Output.implementationCount

        let c3Input = MakeInput(storage: input.storage?.edges.asStatic[3], implementationPosition: input.implementationPosition + implementationCount)
        let c3Output = C3.make(view: view?.c3, input: c3Input)
        edges.append(c3Output)
        implementationCount += c3Output.implementationCount

        let c4Input = MakeInput(storage: input.storage?.edges.asStatic[4], implementationPosition: input.implementationPosition + implementationCount)
        let c4Output = C4.make(view: view?.c4, input: c4Input)
        edges.append(c4Output)
        implementationCount += c4Output.implementationCount

        let c5Input = MakeInput(storage: input.storage?.edges.asStatic[5], implementationPosition: input.implementationPosition + implementationCount)
        let c5Output = C5.make(view: view?.c5, input: c5Input)
        edges.append(c5Output)
        implementationCount += c5Output.implementationCount

        return Self.output(
            node: nil,
            staticEdges: edges,
            implementationPosition: input.implementationPosition,
            implementationCount: implementationCount,
            accessor: view?.accessor
        )
    }

    public static var staticEdgesCount: Int {
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
}
