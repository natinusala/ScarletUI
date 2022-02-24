protocol TestMutator {
    mutating func changeSomething()
}

extension TestMutator {
    mutating func changeSomething() {

    }
}

protocol EquatableStruct {
    static func equals(lhs: Self, rhs: Self) -> Bool
}

extension EquatableStruct where Self: Equatable {
    static func equals(lhs: Self, rhs: Self) -> Bool {
        return lhs == rhs
    }
}

protocol TreeNodeMetadata: EquatableStruct {}

protocol View: TestMutator, TreeNodeMetadata {
    associatedtype Body: View

    var body: Body { get }

    /// Compares this view with its previous version and tells what needs to be done
    /// to the expanded views list in order to migrate from the old version to the new one.
    ///
    /// Ranges in returned operations are relative to this view's expanded list.
    /// If called recursively, the caller needs to offset the ranges to translate them
    /// and make them fit into its own expanded list.
    ///
    /// Order is not important. Positions should match the initial expanded list, without
    /// considering previous operations that might mutate the list and shuffle positions.
    static func makeViews(view: Self, previous: Self?) -> ViewOperations

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

/// Represents the position of a child view inside
/// its parent's expanded list.
typealias ViewPosition = Int

/// An insertion operation.
struct ViewInsertion {
    var newView: AnyView
    var position: ViewPosition

    func offsetBy(_ offset: Int) -> ViewInsertion {
        return ViewInsertion(newView: self.newView, position: self.position + offset)
    }
}

/// A comparison and update (if needed) operation.
struct ViewUpdate {
    var updatedView: AnyView
    var position: ViewPosition

    func offsetBy(_ offset: Int) -> ViewUpdate {
        return ViewUpdate(updatedView: self.updatedView, position: self.position + offset)
    }
}

/// A removal operation.
struct ViewRemoval {
    var position: ViewPosition

    func offsetBy(_ offset: Int) -> ViewRemoval {
        return ViewRemoval(position: self.position + offset)
    }
}

/// Operations to perform on a view's expanded list to migrate it from
/// its current version to the new one.
struct ViewOperations {
    var insertions: [ViewInsertion]
    var updates: [ViewUpdate]
    var removals: [ViewRemoval]

    init(insertions: [ViewInsertion] = [], updates: [ViewUpdate] = [], removals: [ViewRemoval] = []) {
        self.insertions = insertions
        self.updates = updates
        self.removals = removals
    }

    /// Returns a new `ViewOperations` with all operations of this instance and
    /// all of the operations of the given instance, offset by the given amount.
    func appendAndOffset(operations: ViewOperations, offset: Int) -> ViewOperations {
        return ViewOperations(
            insertions: self.insertions + operations.insertions.map { $0.offsetBy(offset) },
            updates: self.updates + operations.updates.map { $0.offsetBy(offset) },
            removals: self.removals + operations.removals.map { $0.offsetBy(offset) }
        )
    }
}

// /// One step to perform to migrate a view's expansion from its previous version
// /// to the updated one.
// enum ViewOperation {
//     /// Insert the given views at the given position.
//     case insert([AnyView], ViewPosition)

//     /// Compare the given view to its previous version and update it if needed.
//     case compareAndUpdate([(AnyView, ViewPosition)])

//     /// Delete all views from the given range.
//     case delete(ViewRange)

//     /// Returns a new view operation that's a copy of this one,
//     /// with every range offset by the given amount.
//     func offsetBy(_ amount: Int) -> ViewOperation {
//         switch self {
//             case let .insert(views, position):
//                 return .insert(views, position + amount)
//             case let .compareAndUpdate(updates):
//                 return .compareAndUpdate(updates.map { (view, position) in (view, position + amount) })
//             case let .delete(range):
//                 return .delete((range.lowerBound + amount)..<(range.upperBound + amount))
//         }
//     }
// }

/// A type-erased view, used internally to access a view's properties.
/// TODO: needs to be a class to prevent duplications between `body` and `children` inside `BodyNode`.
class AnyView: CustomStringConvertible {
    var view: TestMutator
    var viewType: Any.Type

    var isLeaf: Bool

    private var bodyClosure: (Any) -> BodyNode
    private var makeViewsClosure: (Any, BodyNode?) -> ViewOperations
    private var equalsClosure: (Any, AnyView) -> Bool

    init<V: View>(view: V) {
        self.view = view
        self.viewType = V.self

        self.isLeaf = V.Body.self == Never.self

        self.bodyClosure = { view in
            return BodyNode(of: (view as! V).body)
        }

        self.makeViewsClosure = { view, previous in
            if let previous = previous {
                return V.makeViews(view: (view as! V), previous: (previous.body.view as! V))
            }

            return V.makeViews(view: (view as! V), previous: nil)
        }

        self.equalsClosure = { view, newView in
            return V.equals(lhs: (view as! V), rhs: (newView.view as! V))
        }
    }

    var body: BodyNode {
        return self.bodyClosure(self.view)
    }

    func equals(other: AnyView) -> Bool {
        // First compare view type
        guard self.viewType == other.viewType else {
            return false
        }

        // Then compare field by field
        return self.equalsClosure(self.view, other)
    }

    func makeViews(previous: BodyNode?) -> ViewOperations {
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

    /// The body node corresponding to this's view body.
    var children: BodyNode?

    /// Set to `true` to have this view be removed when possible.
    var toBeRemoved = false

    init(view: AnyView) {
        self.view = view
    }

    deinit {
        print("- \(self.view.viewType) killed")
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

    private func makeViews(previous: BodyNode?) -> ViewOperations {
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

        // Update `body` property once every operation is applied
        self.body = next.body
    }

    /// Performs the initial mount: call `makeViews` on `self` without a previous node and apply changes.
    mutating func initialMount() {
        print("Performing initial mount on \(self.body.viewType)")

        self.applyOperations(self.makeViews(previous: nil))

        print("Got \(self.mountedViews.count) mounted views after applying operations of initial mount")
    }

    /// Mutates the body node to apply given operations.
    private mutating func applyOperations(_ operations: ViewOperations) {
        // Avoid mutating the list to preserve the original views positions,
        // otherwise we won't be able to apply all operations:
        //  - Process updates
        //  - Mark all views that need to be removed
        //  - Process insertions, this will mutate the list but it doesn't matter anymore
        //  - Filter the list to remove those marked previously

        // Start with updates
        for update in operations.updates {
            print("  -> Updating \(update.updatedView.viewType) at position \(update.position)")
            self.updateView(at: update.position, with: update.updatedView)
        }

        // Mark removals
        for removal in operations.removals {
            print("  -> Removing \(self.mountedViews[removal.position].view.viewType)")
            self.mountedViews[removal.position].toBeRemoved = true
        }

        // Process insertions
        for insertion in operations.insertions {
            print("  -> Inserting \(insertion.newView.viewType)")
            self.insertView(view: insertion.newView, at: insertion.position)
        }

        // Sweep the list for removed views
        self.mountedViews = self.mountedViews.filter { !$0.toBeRemoved }
    }

    mutating func updateView(at position: ViewPosition, with newView: AnyView) {
        let mountedView = self.mountedViews[position]

        // Compare the two views to detect any change
        print("Comparing \(mountedView.view.viewType) with \(newView.viewType)")
        guard !mountedView.view.equals(other: newView) else {
            print("They are equal")
            return
        }

        print("They are different")

        // If they changed, call `body` again and compare the two bodies
        let newBody = newView.body
        mountedView.children?.update(next: newBody)
    }

    mutating func insertView(view: AnyView, at position: ViewPosition) {
        print("Inserting \(view.description) at position \(position)")

        let mountedView = MountedView(view: view)

        // Perform initial mount
        if !mountedView.view.isLeaf {
            mountedView.children = mountedView.view.body
            mountedView.children?.initialMount()
        }

        // Insert the view
        self.mountedViews.insert(mountedView, at: position)
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

extension Optional: View, TestMutator, EquatableStruct, TreeNodeMetadata where Wrapped: View, Wrapped: Equatable {
    typealias Body = Never

    static func makeViews(view: Self, previous: Self?) -> ViewOperations {
        print("Calling Optional makeViews on \(Self.self) - previous? \(previous == nil ? "no" : "yes")")

        // If there is no previous node and we have a value, always insert (by giving no previous node)
        guard let previous = previous else {
            switch view {
                case .none:
                    return ViewOperations()
                case let .some(view):
                    return Wrapped.makeViews(view: view, previous: nil)
            }
        }

        // Otherwise check every different possibility
        switch (view, previous) {
            // Both are `.none` -> nothing has changed
            case (.none, .none):
                return ViewOperations()
            // Both are `.some` -> call `makeViews` recursively to have an update operation
            case let (.some(view), .some(previous)):
                return Wrapped.makeViews(view: view, previous: previous)
            // Some to none -> remove the view
            case (.none, .some):
                return ViewOperations(removals: [ViewRemoval(position: 0)])
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

struct TupleView2<C0, C1>: View, Equatable where C0: View, C1: View, C0: Equatable, C1: Equatable {
    typealias Body = Never

    let c0: C0
    let c1: C1

    static func makeViews(view: Self, previous: Self?) -> ViewOperations {
        print("Calling TupleView2 makeViews on \(Self.self)")

        let c0Operations = C0.makeViews(view: view.c0, previous: previous?.c0)
        let c1Operations = C1.makeViews(view: view.c1, previous: previous?.c1)

        let c1Offset: Int
        if let previous = previous {
            c1Offset = C0.viewsCount(view: previous.c0)
        } else {
            c1Offset = C0.viewsCount(view: view.c0)
        }

        return c0Operations.appendAndOffset(operations: c1Operations, offset: c1Offset)
    }

    static func viewsCount(view: Self) -> Int {
        return 2
    }
}

extension View {
    /// Default implementation of `makeViews`: insert or update the view.
    /// Removal is handled by its parent view (`Optional` or `ConditionalView`).
    static func makeViews(view: Self, previous: Self?) -> ViewOperations {
        print("Calling View makeViews on \(Self.self) - previous: \(previous == nil ? "no" : "yes")")

        if previous == nil {
            return ViewOperations(insertions: [ViewInsertion(newView: AnyView(view: view), position: 0)])
        }

        return ViewOperations(updates: [ViewUpdate(updatedView: AnyView(view: view), position: 0)])
    }

    /// Default implementation of `viewsCount`: one view, itself.
    static func viewsCount(view: Self) -> Int {
        return 1
    }
}

struct Column<Content>: View, EquatableStruct where Content: View {
    var content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        self.content
    }

    static func equals(lhs: Self, rhs: Self) -> Bool {
        // Always return `false` to force the framework to call body and compare
        // children
        return false
    }
}

struct Text: View, Equatable {
    typealias Body = Never

    let text: String

    init(_ text: String) {
        self.text = text
    }
}

struct MainView: View, Equatable {
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
        self.agagougou.toggle()
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

// Change something in MainView!
rootNode.mountedViews[0].view.view.changeSomething()

// Get a new BodyNode for the changed view
let newNode = rootNode.mountedViews[0].view.body

// Update the current node accordingly
rootNode.mountedViews[0].children!.update(next: newNode)

rootNode.printTree()

// First body node: MainView containing 1 MainView
assert(rootNode.body.viewType == MainView.self)
assert(rootNode.mountedViews[0].view.viewType == MainView.self)

// Second body node: Column containing 1 Column
assert(rootNode.mountedViews[0].children!.body.viewType == Column<TupleView2<Text, Optional<Text>>>.self)
assert(rootNode.mountedViews[0].children!.mountedViews[0].view.viewType == Column<TupleView2<Text, Optional<Text>>>.self)

// Third body node: TupleView containing 1 text (one optional)
assert(rootNode.mountedViews[0].children!.mountedViews[0].children!.body.viewType == TupleView2<Text, Optional<Text>>.self)
assert(rootNode.mountedViews[0].children!.mountedViews[0].children!.mountedViews[0].view.viewType == Text.self)
assert(rootNode.mountedViews[0].children!.mountedViews[0].children!.mountedViews.count == 1)

// Toggle the bool back to test insertion
rootNode.mountedViews[0].view.view.changeSomething()
let newNode2 = rootNode.mountedViews[0].view.body
rootNode.mountedViews[0].children!.update(next: newNode2)

rootNode.printTree()

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
