struct TupleView2<C0, C1>: View where C0: View, C1: View {
    typealias Body = Never

    let c0: C0
    let c1: C1

    static func makeViews(view: Self, previous: Self?) -> ViewOperations {
        let c0Operations = C0.makeViews(view: view.c0, previous: previous?.c0)
        let c1Operations = C1.makeViews(view: view.c1, previous: previous?.c1)

        let c0Offset: Int = 0
        let c1Offset: Int

        if let previous = previous {
            c1Offset = C0.viewsCount(view: previous.c0) + c0Offset
        } else {
            c1Offset = C0.viewsCount(view: view.c0) + c0Offset
        }

        return c0Operations.appendAndOffset(operations: c1Operations, offset: c1Offset)
    }

    static func viewsCount(view: Self) -> Int {
        return 2
    }

    static func equals(lhs: Self, rhs: Self) -> Bool {
        guard C0.equals(lhs: lhs.c0, rhs: rhs.c0) else {
            return false
        }
        guard C1.equals(lhs: lhs.c1, rhs: rhs.c1) else {
            return false
        }

        return true
    }
}

extension ViewBuilder {
    static func buildBlock<C0: View, C1: View>(_ c0: C0, _ c1: C1) -> TupleView2<C0, C1> {
        return .init(c0: c0, c1: c1)
    }
}

struct TupleView3<C0, C1, C2>: View where C0: View, C1: View, C2: View {
    typealias Body = Never

    let c0: C0
    let c1: C1
    let c2: C2

    static func makeViews(view: Self, previous: Self?) -> ViewOperations {
        let c0Operations = C0.makeViews(view: view.c0, previous: previous?.c0)
        let c1Operations = C1.makeViews(view: view.c1, previous: previous?.c1)
        let c2Operations = C2.makeViews(view: view.c2, previous: previous?.c2)

        let c0Offset: Int = 0
        let c1Offset: Int
        let c2Offset: Int

        if let previous = previous {
            c1Offset = C0.viewsCount(view: previous.c0) + c0Offset
            c2Offset = C1.viewsCount(view: previous.c1) + c1Offset
        } else {
            c1Offset = C0.viewsCount(view: view.c0) + c0Offset
            c2Offset = C1.viewsCount(view: view.c1) + c1Offset
        }

        return c0Operations.appendAndOffset(operations: c1Operations, offset: c1Offset).appendAndOffset(operations: c2Operations, offset: c2Offset)
    }

    static func viewsCount(view: Self) -> Int {
        return 3
    }

    static func equals(lhs: Self, rhs: Self) -> Bool {
        guard C0.equals(lhs: lhs.c0, rhs: rhs.c0) else {
            return false
        }
        guard C1.equals(lhs: lhs.c1, rhs: rhs.c1) else {
            return false
        }
        guard C2.equals(lhs: lhs.c2, rhs: rhs.c2) else {
            return false
        }

        return true
    }
}

extension ViewBuilder {
    static func buildBlock<C0: View, C1: View, C2: View>(_ c0: C0, _ c1: C1, _ c2: C2) -> TupleView3<C0, C1, C2> {
        return .init(c0: c0, c1: c1, c2: c2)
    }
}

struct TupleView4<C0, C1, C2, C3>: View where C0: View, C1: View, C2: View, C3: View {
    typealias Body = Never

    let c0: C0
    let c1: C1
    let c2: C2
    let c3: C3

    static func makeViews(view: Self, previous: Self?) -> ViewOperations {
        let c0Operations = C0.makeViews(view: view.c0, previous: previous?.c0)
        let c1Operations = C1.makeViews(view: view.c1, previous: previous?.c1)
        let c2Operations = C2.makeViews(view: view.c2, previous: previous?.c2)
        let c3Operations = C3.makeViews(view: view.c3, previous: previous?.c3)

        let c0Offset: Int = 0
        let c1Offset: Int
        let c2Offset: Int
        let c3Offset: Int

        if let previous = previous {
            c1Offset = C0.viewsCount(view: previous.c0) + c0Offset
            c2Offset = C1.viewsCount(view: previous.c1) + c1Offset
            c3Offset = C2.viewsCount(view: previous.c2) + c2Offset
        } else {
            c1Offset = C0.viewsCount(view: view.c0) + c0Offset
            c2Offset = C1.viewsCount(view: view.c1) + c1Offset
            c3Offset = C2.viewsCount(view: view.c2) + c2Offset
        }

        return c0Operations.appendAndOffset(operations: c1Operations, offset: c1Offset).appendAndOffset(operations: c2Operations, offset: c2Offset).appendAndOffset(operations: c3Operations, offset: c3Offset)
    }

    static func viewsCount(view: Self) -> Int {
        return 4
    }

    static func equals(lhs: Self, rhs: Self) -> Bool {
        guard C0.equals(lhs: lhs.c0, rhs: rhs.c0) else {
            return false
        }
        guard C1.equals(lhs: lhs.c1, rhs: rhs.c1) else {
            return false
        }
        guard C2.equals(lhs: lhs.c2, rhs: rhs.c2) else {
            return false
        }
        guard C3.equals(lhs: lhs.c3, rhs: rhs.c3) else {
            return false
        }

        return true
    }
}

extension ViewBuilder {
    static func buildBlock<C0: View, C1: View, C2: View, C3: View>(_ c0: C0, _ c1: C1, _ c2: C2, _ c3: C3) -> TupleView4<C0, C1, C2, C3> {
        return .init(c0: c0, c1: c1, c2: c2, c3: c3)
    }
}

struct TupleView5<C0, C1, C2, C3, C4>: View where C0: View, C1: View, C2: View, C3: View, C4: View {
    typealias Body = Never

    let c0: C0
    let c1: C1
    let c2: C2
    let c3: C3
    let c4: C4

    static func makeViews(view: Self, previous: Self?) -> ViewOperations {
        let c0Operations = C0.makeViews(view: view.c0, previous: previous?.c0)
        let c1Operations = C1.makeViews(view: view.c1, previous: previous?.c1)
        let c2Operations = C2.makeViews(view: view.c2, previous: previous?.c2)
        let c3Operations = C3.makeViews(view: view.c3, previous: previous?.c3)
        let c4Operations = C4.makeViews(view: view.c4, previous: previous?.c4)

        let c0Offset: Int = 0
        let c1Offset: Int
        let c2Offset: Int
        let c3Offset: Int
        let c4Offset: Int

        if let previous = previous {
            c1Offset = C0.viewsCount(view: previous.c0) + c0Offset
            c2Offset = C1.viewsCount(view: previous.c1) + c1Offset
            c3Offset = C2.viewsCount(view: previous.c2) + c2Offset
            c4Offset = C3.viewsCount(view: previous.c3) + c3Offset
        } else {
            c1Offset = C0.viewsCount(view: view.c0) + c0Offset
            c2Offset = C1.viewsCount(view: view.c1) + c1Offset
            c3Offset = C2.viewsCount(view: view.c2) + c2Offset
            c4Offset = C3.viewsCount(view: view.c3) + c3Offset
        }

        return c0Operations.appendAndOffset(operations: c1Operations, offset: c1Offset).appendAndOffset(operations: c2Operations, offset: c2Offset).appendAndOffset(operations: c3Operations, offset: c3Offset).appendAndOffset(operations: c4Operations, offset: c4Offset)
    }

    static func viewsCount(view: Self) -> Int {
        return 5
    }

    static func equals(lhs: Self, rhs: Self) -> Bool {
        guard C0.equals(lhs: lhs.c0, rhs: rhs.c0) else {
            return false
        }
        guard C1.equals(lhs: lhs.c1, rhs: rhs.c1) else {
            return false
        }
        guard C2.equals(lhs: lhs.c2, rhs: rhs.c2) else {
            return false
        }
        guard C3.equals(lhs: lhs.c3, rhs: rhs.c3) else {
            return false
        }
        guard C4.equals(lhs: lhs.c4, rhs: rhs.c4) else {
            return false
        }

        return true
    }
}

extension ViewBuilder {
    static func buildBlock<C0: View, C1: View, C2: View, C3: View, C4: View>(_ c0: C0, _ c1: C1, _ c2: C2, _ c3: C3, _ c4: C4) -> TupleView5<C0, C1, C2, C3, C4> {
        return .init(c0: c0, c1: c1, c2: c2, c3: c3, c4: c4)
    }
}

struct TupleView6<C0, C1, C2, C3, C4, C5>: View where C0: View, C1: View, C2: View, C3: View, C4: View, C5: View {
    typealias Body = Never

    let c0: C0
    let c1: C1
    let c2: C2
    let c3: C3
    let c4: C4
    let c5: C5

    static func makeViews(view: Self, previous: Self?) -> ViewOperations {
        let c0Operations = C0.makeViews(view: view.c0, previous: previous?.c0)
        let c1Operations = C1.makeViews(view: view.c1, previous: previous?.c1)
        let c2Operations = C2.makeViews(view: view.c2, previous: previous?.c2)
        let c3Operations = C3.makeViews(view: view.c3, previous: previous?.c3)
        let c4Operations = C4.makeViews(view: view.c4, previous: previous?.c4)
        let c5Operations = C5.makeViews(view: view.c5, previous: previous?.c5)

        let c0Offset: Int = 0
        let c1Offset: Int
        let c2Offset: Int
        let c3Offset: Int
        let c4Offset: Int
        let c5Offset: Int

        if let previous = previous {
            c1Offset = C0.viewsCount(view: previous.c0) + c0Offset
            c2Offset = C1.viewsCount(view: previous.c1) + c1Offset
            c3Offset = C2.viewsCount(view: previous.c2) + c2Offset
            c4Offset = C3.viewsCount(view: previous.c3) + c3Offset
            c5Offset = C4.viewsCount(view: previous.c4) + c4Offset
        } else {
            c1Offset = C0.viewsCount(view: view.c0) + c0Offset
            c2Offset = C1.viewsCount(view: view.c1) + c1Offset
            c3Offset = C2.viewsCount(view: view.c2) + c2Offset
            c4Offset = C3.viewsCount(view: view.c3) + c3Offset
            c5Offset = C4.viewsCount(view: view.c4) + c4Offset
        }

        return c0Operations.appendAndOffset(operations: c1Operations, offset: c1Offset).appendAndOffset(operations: c2Operations, offset: c2Offset).appendAndOffset(operations: c3Operations, offset: c3Offset).appendAndOffset(operations: c4Operations, offset: c4Offset).appendAndOffset(operations: c5Operations, offset: c5Offset)
    }

    static func viewsCount(view: Self) -> Int {
        return 6
    }

    static func equals(lhs: Self, rhs: Self) -> Bool {
        guard C0.equals(lhs: lhs.c0, rhs: rhs.c0) else {
            return false
        }
        guard C1.equals(lhs: lhs.c1, rhs: rhs.c1) else {
            return false
        }
        guard C2.equals(lhs: lhs.c2, rhs: rhs.c2) else {
            return false
        }
        guard C3.equals(lhs: lhs.c3, rhs: rhs.c3) else {
            return false
        }
        guard C4.equals(lhs: lhs.c4, rhs: rhs.c4) else {
            return false
        }
        guard C5.equals(lhs: lhs.c5, rhs: rhs.c5) else {
            return false
        }

        return true
    }
}

extension ViewBuilder {
    static func buildBlock<C0: View, C1: View, C2: View, C3: View, C4: View, C5: View>(_ c0: C0, _ c1: C1, _ c2: C2, _ c3: C3, _ c4: C4, _ c5: C5) -> TupleView6<C0, C1, C2, C3, C4, C5> {
        return .init(c0: c0, c1: c1, c2: c2, c3: c3, c4: c4, c5: c5)
    }
}

struct TupleView7<C0, C1, C2, C3, C4, C5, C6>: View where C0: View, C1: View, C2: View, C3: View, C4: View, C5: View, C6: View {
    typealias Body = Never

    let c0: C0
    let c1: C1
    let c2: C2
    let c3: C3
    let c4: C4
    let c5: C5
    let c6: C6

    static func makeViews(view: Self, previous: Self?) -> ViewOperations {
        let c0Operations = C0.makeViews(view: view.c0, previous: previous?.c0)
        let c1Operations = C1.makeViews(view: view.c1, previous: previous?.c1)
        let c2Operations = C2.makeViews(view: view.c2, previous: previous?.c2)
        let c3Operations = C3.makeViews(view: view.c3, previous: previous?.c3)
        let c4Operations = C4.makeViews(view: view.c4, previous: previous?.c4)
        let c5Operations = C5.makeViews(view: view.c5, previous: previous?.c5)
        let c6Operations = C6.makeViews(view: view.c6, previous: previous?.c6)

        let c0Offset: Int = 0
        let c1Offset: Int
        let c2Offset: Int
        let c3Offset: Int
        let c4Offset: Int
        let c5Offset: Int
        let c6Offset: Int

        if let previous = previous {
            c1Offset = C0.viewsCount(view: previous.c0) + c0Offset
            c2Offset = C1.viewsCount(view: previous.c1) + c1Offset
            c3Offset = C2.viewsCount(view: previous.c2) + c2Offset
            c4Offset = C3.viewsCount(view: previous.c3) + c3Offset
            c5Offset = C4.viewsCount(view: previous.c4) + c4Offset
            c6Offset = C5.viewsCount(view: previous.c5) + c5Offset
        } else {
            c1Offset = C0.viewsCount(view: view.c0) + c0Offset
            c2Offset = C1.viewsCount(view: view.c1) + c1Offset
            c3Offset = C2.viewsCount(view: view.c2) + c2Offset
            c4Offset = C3.viewsCount(view: view.c3) + c3Offset
            c5Offset = C4.viewsCount(view: view.c4) + c4Offset
            c6Offset = C5.viewsCount(view: view.c5) + c5Offset
        }

        return c0Operations.appendAndOffset(operations: c1Operations, offset: c1Offset).appendAndOffset(operations: c2Operations, offset: c2Offset).appendAndOffset(operations: c3Operations, offset: c3Offset).appendAndOffset(operations: c4Operations, offset: c4Offset).appendAndOffset(operations: c5Operations, offset: c5Offset).appendAndOffset(operations: c6Operations, offset: c6Offset)
    }

    static func viewsCount(view: Self) -> Int {
        return 7
    }

    static func equals(lhs: Self, rhs: Self) -> Bool {
        guard C0.equals(lhs: lhs.c0, rhs: rhs.c0) else {
            return false
        }
        guard C1.equals(lhs: lhs.c1, rhs: rhs.c1) else {
            return false
        }
        guard C2.equals(lhs: lhs.c2, rhs: rhs.c2) else {
            return false
        }
        guard C3.equals(lhs: lhs.c3, rhs: rhs.c3) else {
            return false
        }
        guard C4.equals(lhs: lhs.c4, rhs: rhs.c4) else {
            return false
        }
        guard C5.equals(lhs: lhs.c5, rhs: rhs.c5) else {
            return false
        }
        guard C6.equals(lhs: lhs.c6, rhs: rhs.c6) else {
            return false
        }

        return true
    }
}

extension ViewBuilder {
    static func buildBlock<C0: View, C1: View, C2: View, C3: View, C4: View, C5: View, C6: View>(_ c0: C0, _ c1: C1, _ c2: C2, _ c3: C3, _ c4: C4, _ c5: C5, _ c6: C6) -> TupleView7<C0, C1, C2, C3, C4, C5, C6> {
        return .init(c0: c0, c1: c1, c2: c2, c3: c3, c4: c4, c5: c5, c6: c6)
    }
}

struct TupleView8<C0, C1, C2, C3, C4, C5, C6, C7>: View where C0: View, C1: View, C2: View, C3: View, C4: View, C5: View, C6: View, C7: View {
    typealias Body = Never

    let c0: C0
    let c1: C1
    let c2: C2
    let c3: C3
    let c4: C4
    let c5: C5
    let c6: C6
    let c7: C7

    static func makeViews(view: Self, previous: Self?) -> ViewOperations {
        let c0Operations = C0.makeViews(view: view.c0, previous: previous?.c0)
        let c1Operations = C1.makeViews(view: view.c1, previous: previous?.c1)
        let c2Operations = C2.makeViews(view: view.c2, previous: previous?.c2)
        let c3Operations = C3.makeViews(view: view.c3, previous: previous?.c3)
        let c4Operations = C4.makeViews(view: view.c4, previous: previous?.c4)
        let c5Operations = C5.makeViews(view: view.c5, previous: previous?.c5)
        let c6Operations = C6.makeViews(view: view.c6, previous: previous?.c6)
        let c7Operations = C7.makeViews(view: view.c7, previous: previous?.c7)

        let c0Offset: Int = 0
        let c1Offset: Int
        let c2Offset: Int
        let c3Offset: Int
        let c4Offset: Int
        let c5Offset: Int
        let c6Offset: Int
        let c7Offset: Int

        if let previous = previous {
            c1Offset = C0.viewsCount(view: previous.c0) + c0Offset
            c2Offset = C1.viewsCount(view: previous.c1) + c1Offset
            c3Offset = C2.viewsCount(view: previous.c2) + c2Offset
            c4Offset = C3.viewsCount(view: previous.c3) + c3Offset
            c5Offset = C4.viewsCount(view: previous.c4) + c4Offset
            c6Offset = C5.viewsCount(view: previous.c5) + c5Offset
            c7Offset = C6.viewsCount(view: previous.c6) + c6Offset
        } else {
            c1Offset = C0.viewsCount(view: view.c0) + c0Offset
            c2Offset = C1.viewsCount(view: view.c1) + c1Offset
            c3Offset = C2.viewsCount(view: view.c2) + c2Offset
            c4Offset = C3.viewsCount(view: view.c3) + c3Offset
            c5Offset = C4.viewsCount(view: view.c4) + c4Offset
            c6Offset = C5.viewsCount(view: view.c5) + c5Offset
            c7Offset = C6.viewsCount(view: view.c6) + c6Offset
        }

        return c0Operations.appendAndOffset(operations: c1Operations, offset: c1Offset).appendAndOffset(operations: c2Operations, offset: c2Offset).appendAndOffset(operations: c3Operations, offset: c3Offset).appendAndOffset(operations: c4Operations, offset: c4Offset).appendAndOffset(operations: c5Operations, offset: c5Offset).appendAndOffset(operations: c6Operations, offset: c6Offset).appendAndOffset(operations: c7Operations, offset: c7Offset)
    }

    static func viewsCount(view: Self) -> Int {
        return 8
    }

    static func equals(lhs: Self, rhs: Self) -> Bool {
        guard C0.equals(lhs: lhs.c0, rhs: rhs.c0) else {
            return false
        }
        guard C1.equals(lhs: lhs.c1, rhs: rhs.c1) else {
            return false
        }
        guard C2.equals(lhs: lhs.c2, rhs: rhs.c2) else {
            return false
        }
        guard C3.equals(lhs: lhs.c3, rhs: rhs.c3) else {
            return false
        }
        guard C4.equals(lhs: lhs.c4, rhs: rhs.c4) else {
            return false
        }
        guard C5.equals(lhs: lhs.c5, rhs: rhs.c5) else {
            return false
        }
        guard C6.equals(lhs: lhs.c6, rhs: rhs.c6) else {
            return false
        }
        guard C7.equals(lhs: lhs.c7, rhs: rhs.c7) else {
            return false
        }

        return true
    }
}

extension ViewBuilder {
    static func buildBlock<C0: View, C1: View, C2: View, C3: View, C4: View, C5: View, C6: View, C7: View>(_ c0: C0, _ c1: C1, _ c2: C2, _ c3: C3, _ c4: C4, _ c5: C5, _ c6: C6, _ c7: C7) -> TupleView8<C0, C1, C2, C3, C4, C5, C6, C7> {
        return .init(c0: c0, c1: c1, c2: c2, c3: c3, c4: c4, c5: c5, c6: c6, c7: c7)
    }
}

struct TupleView9<C0, C1, C2, C3, C4, C5, C6, C7, C8>: View where C0: View, C1: View, C2: View, C3: View, C4: View, C5: View, C6: View, C7: View, C8: View {
    typealias Body = Never

    let c0: C0
    let c1: C1
    let c2: C2
    let c3: C3
    let c4: C4
    let c5: C5
    let c6: C6
    let c7: C7
    let c8: C8

    static func makeViews(view: Self, previous: Self?) -> ViewOperations {
        let c0Operations = C0.makeViews(view: view.c0, previous: previous?.c0)
        let c1Operations = C1.makeViews(view: view.c1, previous: previous?.c1)
        let c2Operations = C2.makeViews(view: view.c2, previous: previous?.c2)
        let c3Operations = C3.makeViews(view: view.c3, previous: previous?.c3)
        let c4Operations = C4.makeViews(view: view.c4, previous: previous?.c4)
        let c5Operations = C5.makeViews(view: view.c5, previous: previous?.c5)
        let c6Operations = C6.makeViews(view: view.c6, previous: previous?.c6)
        let c7Operations = C7.makeViews(view: view.c7, previous: previous?.c7)
        let c8Operations = C8.makeViews(view: view.c8, previous: previous?.c8)

        let c0Offset: Int = 0
        let c1Offset: Int
        let c2Offset: Int
        let c3Offset: Int
        let c4Offset: Int
        let c5Offset: Int
        let c6Offset: Int
        let c7Offset: Int
        let c8Offset: Int

        if let previous = previous {
            c1Offset = C0.viewsCount(view: previous.c0) + c0Offset
            c2Offset = C1.viewsCount(view: previous.c1) + c1Offset
            c3Offset = C2.viewsCount(view: previous.c2) + c2Offset
            c4Offset = C3.viewsCount(view: previous.c3) + c3Offset
            c5Offset = C4.viewsCount(view: previous.c4) + c4Offset
            c6Offset = C5.viewsCount(view: previous.c5) + c5Offset
            c7Offset = C6.viewsCount(view: previous.c6) + c6Offset
            c8Offset = C7.viewsCount(view: previous.c7) + c7Offset
        } else {
            c1Offset = C0.viewsCount(view: view.c0) + c0Offset
            c2Offset = C1.viewsCount(view: view.c1) + c1Offset
            c3Offset = C2.viewsCount(view: view.c2) + c2Offset
            c4Offset = C3.viewsCount(view: view.c3) + c3Offset
            c5Offset = C4.viewsCount(view: view.c4) + c4Offset
            c6Offset = C5.viewsCount(view: view.c5) + c5Offset
            c7Offset = C6.viewsCount(view: view.c6) + c6Offset
            c8Offset = C7.viewsCount(view: view.c7) + c7Offset
        }

        return c0Operations.appendAndOffset(operations: c1Operations, offset: c1Offset).appendAndOffset(operations: c2Operations, offset: c2Offset).appendAndOffset(operations: c3Operations, offset: c3Offset).appendAndOffset(operations: c4Operations, offset: c4Offset).appendAndOffset(operations: c5Operations, offset: c5Offset).appendAndOffset(operations: c6Operations, offset: c6Offset).appendAndOffset(operations: c7Operations, offset: c7Offset).appendAndOffset(operations: c8Operations, offset: c8Offset)
    }

    static func viewsCount(view: Self) -> Int {
        return 9
    }

    static func equals(lhs: Self, rhs: Self) -> Bool {
        guard C0.equals(lhs: lhs.c0, rhs: rhs.c0) else {
            return false
        }
        guard C1.equals(lhs: lhs.c1, rhs: rhs.c1) else {
            return false
        }
        guard C2.equals(lhs: lhs.c2, rhs: rhs.c2) else {
            return false
        }
        guard C3.equals(lhs: lhs.c3, rhs: rhs.c3) else {
            return false
        }
        guard C4.equals(lhs: lhs.c4, rhs: rhs.c4) else {
            return false
        }
        guard C5.equals(lhs: lhs.c5, rhs: rhs.c5) else {
            return false
        }
        guard C6.equals(lhs: lhs.c6, rhs: rhs.c6) else {
            return false
        }
        guard C7.equals(lhs: lhs.c7, rhs: rhs.c7) else {
            return false
        }
        guard C8.equals(lhs: lhs.c8, rhs: rhs.c8) else {
            return false
        }

        return true
    }
}

extension ViewBuilder {
    static func buildBlock<C0: View, C1: View, C2: View, C3: View, C4: View, C5: View, C6: View, C7: View, C8: View>(_ c0: C0, _ c1: C1, _ c2: C2, _ c3: C3, _ c4: C4, _ c5: C5, _ c6: C6, _ c7: C7, _ c8: C8) -> TupleView9<C0, C1, C2, C3, C4, C5, C6, C7, C8> {
        return .init(c0: c0, c1: c1, c2: c2, c3: c3, c4: c4, c5: c5, c6: c6, c7: c7, c8: c8)
    }
}

struct TupleView10<C0, C1, C2, C3, C4, C5, C6, C7, C8, C9>: View where C0: View, C1: View, C2: View, C3: View, C4: View, C5: View, C6: View, C7: View, C8: View, C9: View {
    typealias Body = Never

    let c0: C0
    let c1: C1
    let c2: C2
    let c3: C3
    let c4: C4
    let c5: C5
    let c6: C6
    let c7: C7
    let c8: C8
    let c9: C9

    static func makeViews(view: Self, previous: Self?) -> ViewOperations {
        let c0Operations = C0.makeViews(view: view.c0, previous: previous?.c0)
        let c1Operations = C1.makeViews(view: view.c1, previous: previous?.c1)
        let c2Operations = C2.makeViews(view: view.c2, previous: previous?.c2)
        let c3Operations = C3.makeViews(view: view.c3, previous: previous?.c3)
        let c4Operations = C4.makeViews(view: view.c4, previous: previous?.c4)
        let c5Operations = C5.makeViews(view: view.c5, previous: previous?.c5)
        let c6Operations = C6.makeViews(view: view.c6, previous: previous?.c6)
        let c7Operations = C7.makeViews(view: view.c7, previous: previous?.c7)
        let c8Operations = C8.makeViews(view: view.c8, previous: previous?.c8)
        let c9Operations = C9.makeViews(view: view.c9, previous: previous?.c9)

        let c0Offset: Int = 0
        let c1Offset: Int
        let c2Offset: Int
        let c3Offset: Int
        let c4Offset: Int
        let c5Offset: Int
        let c6Offset: Int
        let c7Offset: Int
        let c8Offset: Int
        let c9Offset: Int

        if let previous = previous {
            c1Offset = C0.viewsCount(view: previous.c0) + c0Offset
            c2Offset = C1.viewsCount(view: previous.c1) + c1Offset
            c3Offset = C2.viewsCount(view: previous.c2) + c2Offset
            c4Offset = C3.viewsCount(view: previous.c3) + c3Offset
            c5Offset = C4.viewsCount(view: previous.c4) + c4Offset
            c6Offset = C5.viewsCount(view: previous.c5) + c5Offset
            c7Offset = C6.viewsCount(view: previous.c6) + c6Offset
            c8Offset = C7.viewsCount(view: previous.c7) + c7Offset
            c9Offset = C8.viewsCount(view: previous.c8) + c8Offset
        } else {
            c1Offset = C0.viewsCount(view: view.c0) + c0Offset
            c2Offset = C1.viewsCount(view: view.c1) + c1Offset
            c3Offset = C2.viewsCount(view: view.c2) + c2Offset
            c4Offset = C3.viewsCount(view: view.c3) + c3Offset
            c5Offset = C4.viewsCount(view: view.c4) + c4Offset
            c6Offset = C5.viewsCount(view: view.c5) + c5Offset
            c7Offset = C6.viewsCount(view: view.c6) + c6Offset
            c8Offset = C7.viewsCount(view: view.c7) + c7Offset
            c9Offset = C8.viewsCount(view: view.c8) + c8Offset
        }

        return c0Operations.appendAndOffset(operations: c1Operations, offset: c1Offset).appendAndOffset(operations: c2Operations, offset: c2Offset).appendAndOffset(operations: c3Operations, offset: c3Offset).appendAndOffset(operations: c4Operations, offset: c4Offset).appendAndOffset(operations: c5Operations, offset: c5Offset).appendAndOffset(operations: c6Operations, offset: c6Offset).appendAndOffset(operations: c7Operations, offset: c7Offset).appendAndOffset(operations: c8Operations, offset: c8Offset).appendAndOffset(operations: c9Operations, offset: c9Offset)
    }

    static func viewsCount(view: Self) -> Int {
        return 10
    }

    static func equals(lhs: Self, rhs: Self) -> Bool {
        guard C0.equals(lhs: lhs.c0, rhs: rhs.c0) else {
            return false
        }
        guard C1.equals(lhs: lhs.c1, rhs: rhs.c1) else {
            return false
        }
        guard C2.equals(lhs: lhs.c2, rhs: rhs.c2) else {
            return false
        }
        guard C3.equals(lhs: lhs.c3, rhs: rhs.c3) else {
            return false
        }
        guard C4.equals(lhs: lhs.c4, rhs: rhs.c4) else {
            return false
        }
        guard C5.equals(lhs: lhs.c5, rhs: rhs.c5) else {
            return false
        }
        guard C6.equals(lhs: lhs.c6, rhs: rhs.c6) else {
            return false
        }
        guard C7.equals(lhs: lhs.c7, rhs: rhs.c7) else {
            return false
        }
        guard C8.equals(lhs: lhs.c8, rhs: rhs.c8) else {
            return false
        }
        guard C9.equals(lhs: lhs.c9, rhs: rhs.c9) else {
            return false
        }

        return true
    }
}

extension ViewBuilder {
    static func buildBlock<C0: View, C1: View, C2: View, C3: View, C4: View, C5: View, C6: View, C7: View, C8: View, C9: View>(_ c0: C0, _ c1: C1, _ c2: C2, _ c3: C3, _ c4: C4, _ c5: C5, _ c6: C6, _ c7: C7, _ c8: C8, _ c9: C9) -> TupleView10<C0, C1, C2, C3, C4, C5, C6, C7, C8, C9> {
        return .init(c0: c0, c1: c1, c2: c2, c3: c3, c4: c4, c5: c5, c6: c6, c7: c7, c8: c8, c9: c9)
    }
}
