protocol TestMutator {
    mutating func changeSomething()
}

extension TestMutator {
    mutating func changeSomething() {

    }
}

protocol View: TestMutator {
    associatedtype Body: View

    var body: Body { get }

    /// Compares this view with its previous version and tells what needs to be done
    /// to the expanded views list in order to migrate from the old version to the new one.
    /// Ranges in returned operations are relative to this view's expanded list.
    /// If called recursively, the caller needs to offset the ranges to translate them
    /// and make them fit into its own expanded list.
    static func makeViews(view: Self, previous: Self?) -> [ViewOperation]

    /// Returns the number of expanded views that make that view.
    static func viewsCount(view: Self) -> Int
}

extension Never: View {
    var body: Never {
        fatalError()
    }
}

extension View where Body == Never {
    var body: Never {
        fatalError()
    }
}

typealias ViewPosition = Int
typealias ViewRange = Range<ViewPosition>

/// One step to perform to migrate a view's expansion from its previous version
/// to the updated one.
enum ViewOperation {
    /// Insert the given views at the given position.
    case insert([AnyView], ViewPosition)

    /// Compare the given view to its previous version and update it if needed.
    case update([(AnyView, ViewPosition)])

    /// Delete all views from the given range.
    case delete(ViewRange)

    /// Returns a new view operation that's a copy of this one,
    /// with every range offset by the given amount.
    func offsetBy(_ amount: Int) -> ViewOperation {
        switch self {
            case let .insert(views, position):
                return .insert(views, position + amount)
            case let .update(updates):
                return .update(updates.map { (view, position) in (view, position + amount) })
            case let .delete(range):
                return .delete((range.lowerBound + amount)..<(range.upperBound + amount))
        }
    }
}

/// A type-erased view, used internally to access a view's properties.
/// TODO: needs to be a class to prevent duplications between `body` and `children` inside `BodyNode`.
class AnyView: CustomStringConvertible {
    var view: TestMutator
    var viewType: Any.Type

    var isLeaf: Bool

    private var bodyClosure: (Any) -> BodyNode
    private var makeViewsClosure: (Any, BodyNode?) -> [ViewOperation]

    init<V: View>(view: V) {
        self.view = view
        self.viewType = V.self

        self.isLeaf = V.Body.self == Never.self

        self.bodyClosure = { view in
            return BodyNode(of: (view as! V).body)
        }

        self.makeViewsClosure = { view, previous in
            return V.makeViews(view: (view as! V), previous: (previous?.body as? V))
        }
    }

    var body: BodyNode {
        return self.bodyClosure(self.view)
    }

    func makeViews(previous: BodyNode?) -> [ViewOperation] {
        return self.makeViewsClosure(self.view, previous)
    }

    var description: String {
        return "AnyView<\(self.viewType)>"
    }
}

/// A mounted view.
/// Must be a class for the state setter / body refresh process: the mounted view needs to escape
/// in the setter closure to be able to update itself (replace any changed child).
class MountedView {
    let view: AnyView

    var children: BodyNode?

    init(view: AnyView) {
        self.view = view
    }
}

/// The result of a body property call, aka. all children of a view.
/// TODO: turn `AnyView` into a class then make another step before calling body that translates `TupleView`, `Optional` and `ConditionalView` into counterparts that use `AnyView` instead of `View`, to prevent duplicating views between `body` and `children` in BodyNode (use the same `AnyView` reference for both)
struct BodyNode {
    var body: AnyView

    var mountedViews = [MountedView]()

    init<V: View>(of body: V) {
        self.body = AnyView(view: body)
    }

    private func makeViews(previous: BodyNode?) -> [ViewOperation] {
        if let previous = previous {
            if self.body.viewType != previous.body.viewType {
                fatalError("`makeViews(previous:)` called with two bodies of a different type: `\(self.body.viewType)` and `\(previous.body.viewType)`")
            }
        }

        return self.body.makeViews(previous: previous)
    }

    /// Compare the node to the next one and updates the mounted views to apply the changes.
    mutating func update(next: BodyNode) {
        // Call `makeViews` on the new node giving ourselves as the previous node
        // to get the list of changes to apply
        self.applyOperations(next.makeViews(previous: self))
    }

    /// Performs the initial mount: call `makeViews` on `self` without a previous node and apply changes.
    /// Then, for every mounted view, call its body property and perform the initial mount as well.
    mutating func initialMount() {
        print("Performing initial mount on \(self.body.viewType)")

        self.applyOperations(self.makeViews(previous: nil))

        print("Got \(self.mountedViews.count) mounted views after applying operations of initial mount")
        for mountedView in self.mountedViews {
            if !mountedView.view.isLeaf {
                mountedView.children = mountedView.view.body
                mountedView.children?.initialMount()
            }
        }
    }

    /// Mutates the body node to apply given operations.
    private mutating func applyOperations(_ operations: [ViewOperation]) {
        for operation in operations {
            switch operation {
                case let .insert(views, position):
                    self.insert(views: views, at: position)
                default:
                    fatalError("Unimplemented")
            }
        }
    }

    mutating func insert(views: [AnyView], at position: ViewPosition) {
        print("Inserting \(views.map { $0.description }) at position \(position)")
        self.mountedViews.insert(contentsOf: views.map { MountedView(view: $0) }, at: position)
    }

    func printTree(indent: Int = 0) {
        var str = String(repeating: " ", count: indent)
        print("\(str)BodyNode<\(self.body.viewType)>")
        str += "- "

        for mountedView in self.mountedViews {
            print("\(str)\(mountedView.view.viewType)")
            mountedView.children?.printTree(indent: indent + 4)
        }
    }
}

extension Optional: View, TestMutator where Wrapped: View {
    typealias Body = Never

    static func makeViews(view: Self, previous: Self?) -> [ViewOperation] {
        // If there is no previous node and we have a value, always insert (by giving no previous node)
        guard let previous = previous else {
            switch view {
                case .none:
                    return []
                case let .some(view):
                    return Wrapped.makeViews(view: view, previous: nil)
            }
        }

        // Otherwise check every different possibility
        switch (view, previous) {
            // Both are `.none` -> nothing changed
            case (.none, .none):
                return []
            // Both are `.some` -> call `makeViews` recursively to have an update operation
            case let (.some(view), .some(previous)):
                return Wrapped.makeViews(view: view, previous: previous)
            // Some to none -> remove the view
            case (.none, .some):
                return [.delete(0..<1)]
            // None to some -> call `makeViews` recursively without a previous node to have an insert operation
            case let (.some(view), .none):
                return Wrapped.makeViews(view: view, previous: nil)
        }
    }

    static func viewsCount(view: Self) -> Int {
        switch view {
            case .none:
                return 0
            case let .some(view):
                return Wrapped.viewsCount(view: view)
        }
    }
}

@resultBuilder
struct ViewBuilder {
    static func buildBlock() -> View? {
        return nil
    }

    static func buildIf<Content: View>(_ content: Content?) -> Content? {
        return content
    }

    static func buildBlock<Content: View>(_ content: Content) -> Content {
        return content
    }

    static func buildBlock<C0: View, C1: View>(_ c0: C0, _ c1: C1) -> TupleView2<C0, C1> {
        return .init(c0: c0, c1: c1)
    }
}

struct TupleView2<C0, C1>: View where C0: View, C1: View {
    typealias Body = Never

    let c0: C0
    let c1: C1

    static func makeViews(view: Self, previous: Self?) -> [ViewOperation] {
        print("Calling makeViews on \(Self.self)")

        let c0Operations = C0.makeViews(view: view.c0, previous: previous?.c0)
        let c1Operations = C1.makeViews(view: view.c1, previous: previous?.c1)

        let c1Offset: Int
        if let previous = previous {
            c1Offset = C0.viewsCount(view: previous.c0)
        } else {
            c1Offset = C0.viewsCount(view: view.c0)
        }

        return c0Operations + c1Operations.map { $0.offsetBy(c1Offset) }
    }

    static func viewsCount(view: Self) -> Int {
        return 2
    }
}

extension View {
    /// Default implementation of `makeViews`: insert or update the view.
    /// Removal is handled by its parent view (`Optional` or `ConditionalView`).
    static func makeViews(view: Self, previous: Self?) -> [ViewOperation] {
        print("Calling makeViews on \(Self.self)")

        if previous == nil {
            return [.insert([AnyView(view: view)], 0)]
        }

        return [.update([(AnyView(view: view), 0)])]
    }

    /// Default implementation of `viewsCount`: one view, itself.
    static func viewsCount(view: Self) -> Int {
        return 1
    }
}

struct Column<Content>: View where Content: View {
    var content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        self.content
    }
}

struct Text: View {
    typealias Body = Never

    let text: String

    init(_ text: String) {
        self.text = text
    }
}

struct MainView: View {
    var agagougou = true

    var body: some View {
        Column {
            Text("Some text 1")

            if agagougou {
                Text("Some text 2")
            }
        }
    }

    mutating func changeSomething() {
        print("-> Changing something!")
        self.agagougou = true
    }
}

// Create the root node
var rootNode = BodyNode(of: MainView())

// Make initial mount (recursive)
rootNode.initialMount()

// First body node: MainView containing 1 MainView
assert(rootNode.body.viewType == MainView.self)
assert(rootNode.mountedViews[0].view.viewType == MainView.self)

// Second body node: Column containing 1 Column
assert(rootNode.mountedViews[0].children!.body.viewType == Column<TupleView2<Text, Optional<Text>>>.self)
assert(rootNode.mountedViews[0].children!.mountedViews[0].view.viewType == Column<TupleView2<Text, Optional<Text>>>.self)

// Third body node: TupleView containing 2 texts (one optional)
assert(rootNode.mountedViews[0].children!.mountedViews[0].children!.body.viewType == TupleView2<Text, Optional<Text>>.self)
assert(rootNode.mountedViews[0].children!.mountedViews[0].children!.mountedViews[0].view.viewType == Text.self)
assert(rootNode.mountedViews[0].children!.mountedViews[0].children!.mountedViews[1].view.viewType == Text.self)

rootNode.printTree()

// Change something!
rootNode.mountedViews[0].view.view.changeSomething()

// Get a new BodyNode for the changed view
let newNode = rootNode.mountedViews[0].view.body

// Update the current node accordingly
rootNode.update(next: newNode)
