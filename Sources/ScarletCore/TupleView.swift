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
    let c0: C0
    let c1: C1

    public static var staticChildrenCount: Int {
        return 2
    }

    public init(_ c0: C0, _ c1: C1) {
        self.c0 = c0
        self.c1 = c1
    }

    public static func makeChildren(view: Self) -> ChildrenOutput {
        return ChildrenOutput(staticChildren: [
            AnyElement(view: view.c0),
            AnyElement(view: view.c1),
        ])
    }
}

public struct TupleView3<C0, C1, C2>: View where C0: View, C1: View, C2: View {
    let c0: C0
    let c1: C1
    let c2: C2

    public static var staticChildrenCount: Int {
        return 3
    }

    public init(_ c0: C0, _ c1: C1, _ c2: C2) {
        self.c0 = c0
        self.c1 = c1
        self.c2 = c2
    }

    public static func makeChildren(view: Self) -> ChildrenOutput {
        return ChildrenOutput(staticChildren: [
            AnyElement(view: view.c0),
            AnyElement(view: view.c1),
            AnyElement(view: view.c2),
        ])
    }
}

public struct TupleView4<C0, C1, C2, C3>: View where C0: View, C1: View, C2: View, C3: View {
    let c0: C0
    let c1: C1
    let c2: C2
    let c3: C3

    public static var staticChildrenCount: Int {
        return 4
    }

    public init(_ c0: C0, _ c1: C1, _ c2: C2, _ c3: C3) {
        self.c0 = c0
        self.c1 = c1
        self.c2 = c2
        self.c3 = c3
    }

    public static func makeChildren(view: Self) -> ChildrenOutput {
        return ChildrenOutput(staticChildren: [
            AnyElement(view: view.c0),
            AnyElement(view: view.c1),
            AnyElement(view: view.c2),
            AnyElement(view: view.c3),
        ])
    }
}

public struct TupleView5<C0, C1, C2, C3, C4>: View where C0: View, C1: View, C2: View, C3: View, C4: View {
    let c0: C0
    let c1: C1
    let c2: C2
    let c3: C3
    let c4: C4

    public static var staticChildrenCount: Int {
        return 5
    }

    public init(_ c0: C0, _ c1: C1, _ c2: C2, _ c3: C3, _ c4: C4) {
        self.c0 = c0
        self.c1 = c1
        self.c2 = c2
        self.c3 = c3
        self.c4 = c4
    }

    public static func makeChildren(view: Self) -> ChildrenOutput {
        return ChildrenOutput(staticChildren: [
            AnyElement(view: view.c0),
            AnyElement(view: view.c1),
            AnyElement(view: view.c2),
            AnyElement(view: view.c3),
            AnyElement(view: view.c4),
        ])
    }
}

public struct TupleView6<C0, C1, C2, C3, C4, C5>: View where C0: View, C1: View, C2: View, C3: View, C4: View, C5: View {
    let c0: C0
    let c1: C1
    let c2: C2
    let c3: C3
    let c4: C4
    let c5: C5

    public static var staticChildrenCount: Int {
        return 6
    }

    public init(_ c0: C0, _ c1: C1, _ c2: C2, _ c3: C3, _ c4: C4, _ c5: C5) {
        self.c0 = c0
        self.c1 = c1
        self.c2 = c2
        self.c3 = c3
        self.c4 = c4
        self.c5 = c5
    }

    public static func makeChildren(view: Self) -> ChildrenOutput {
        return ChildrenOutput(staticChildren: [
            AnyElement(view: view.c0),
            AnyElement(view: view.c1),
            AnyElement(view: view.c2),
            AnyElement(view: view.c3),
            AnyElement(view: view.c4),
            AnyElement(view: view.c5),
        ])
    }
}

public struct TupleView7<C0, C1, C2, C3, C4, C5, C6>: View where C0: View, C1: View, C2: View, C3: View, C4: View, C5: View, C6: View {
    let c0: C0
    let c1: C1
    let c2: C2
    let c3: C3
    let c4: C4
    let c5: C5
    let c6: C6

    public static var staticChildrenCount: Int {
        return 7
    }

    public init(_ c0: C0, _ c1: C1, _ c2: C2, _ c3: C3, _ c4: C4, _ c5: C5, _ c6: C6) {
        self.c0 = c0
        self.c1 = c1
        self.c2 = c2
        self.c3 = c3
        self.c4 = c4
        self.c5 = c5
        self.c6 = c6
    }

    public static func makeChildren(view: Self) -> ChildrenOutput {
        return ChildrenOutput(staticChildren: [
            AnyElement(view: view.c0),
            AnyElement(view: view.c1),
            AnyElement(view: view.c2),
            AnyElement(view: view.c3),
            AnyElement(view: view.c4),
            AnyElement(view: view.c5),
            AnyElement(view: view.c6),
        ])
    }
}

public struct TupleView8<C0, C1, C2, C3, C4, C5, C6, C7>: View where C0: View, C1: View, C2: View, C3: View, C4: View, C5: View, C6: View, C7: View {
    let c0: C0
    let c1: C1
    let c2: C2
    let c3: C3
    let c4: C4
    let c5: C5
    let c6: C6
    let c7: C7

    public static var staticChildrenCount: Int {
        return 8
    }

    public init(_ c0: C0, _ c1: C1, _ c2: C2, _ c3: C3, _ c4: C4, _ c5: C5, _ c6: C6, _ c7: C7) {
        self.c0 = c0
        self.c1 = c1
        self.c2 = c2
        self.c3 = c3
        self.c4 = c4
        self.c5 = c5
        self.c6 = c6
        self.c7 = c7
    }

    public static func makeChildren(view: Self) -> ChildrenOutput {
        return ChildrenOutput(staticChildren: [
            AnyElement(view: view.c0),
            AnyElement(view: view.c1),
            AnyElement(view: view.c2),
            AnyElement(view: view.c3),
            AnyElement(view: view.c4),
            AnyElement(view: view.c5),
            AnyElement(view: view.c6),
            AnyElement(view: view.c7),
        ])
    }
}

public struct TupleView9<C0, C1, C2, C3, C4, C5, C6, C7, C8>: View where C0: View, C1: View, C2: View, C3: View, C4: View, C5: View, C6: View, C7: View, C8: View {
    let c0: C0
    let c1: C1
    let c2: C2
    let c3: C3
    let c4: C4
    let c5: C5
    let c6: C6
    let c7: C7
    let c8: C8

    public static var staticChildrenCount: Int {
        return 9
    }

    public init(_ c0: C0, _ c1: C1, _ c2: C2, _ c3: C3, _ c4: C4, _ c5: C5, _ c6: C6, _ c7: C7, _ c8: C8) {
        self.c0 = c0
        self.c1 = c1
        self.c2 = c2
        self.c3 = c3
        self.c4 = c4
        self.c5 = c5
        self.c6 = c6
        self.c7 = c7
        self.c8 = c8
    }

    public static func makeChildren(view: Self) -> ChildrenOutput {
        return ChildrenOutput(staticChildren: [
            AnyElement(view: view.c0),
            AnyElement(view: view.c1),
            AnyElement(view: view.c2),
            AnyElement(view: view.c3),
            AnyElement(view: view.c4),
            AnyElement(view: view.c5),
            AnyElement(view: view.c6),
            AnyElement(view: view.c7),
            AnyElement(view: view.c8),
        ])
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

    static func buildBlock<C0: View, C1: View, C2: View, C3: View, C4: View, C5: View, C6: View>(_ c0: C0, _ c1: C1, _ c2: C2, _ c3: C3, _ c4: C4, _ c5: C5, _ c6: C6) -> TupleView7<C0, C1, C2, C3, C4, C5, C6> {
        return TupleView7(c0, c1, c2, c3, c4, c5, c6)
    }

    static func buildBlock<C0: View, C1: View, C2: View, C3: View, C4: View, C5: View, C6: View, C7: View>(_ c0: C0, _ c1: C1, _ c2: C2, _ c3: C3, _ c4: C4, _ c5: C5, _ c6: C6, _ c7: C7) -> TupleView8<C0, C1, C2, C3, C4, C5, C6, C7> {
        return TupleView8(c0, c1, c2, c3, c4, c5, c6, c7)
    }

    static func buildBlock<C0: View, C1: View, C2: View, C3: View, C4: View, C5: View, C6: View, C7: View, C8: View>(_ c0: C0, _ c1: C1, _ c2: C2, _ c3: C3, _ c4: C4, _ c5: C5, _ c6: C6, _ c7: C7, _ c8: C8) -> TupleView9<C0, C1, C2, C3, C4, C5, C6, C7, C8> {
        return TupleView9(c0, c1, c2, c3, c4, c5, c6, c7, c8)
    }
}
