import Foundation
import Dispatch

import Echo

class StateLocation {
    typealias Getter = () -> Any
    typealias Setter = (Any) -> ()

    let getter: Getter
    let setter: Setter

    init(setter: @escaping Setter, getter: @escaping Getter) {
        self.getter = getter
        self.setter = setter
    }
}

protocol DynamicProperty {
    mutating func update()
}

@propertyWrapper
struct State<Value>: DynamicProperty {
    /// The current value.
    var value: Value

    /// The stored value location.
    var location: StateLocation? {
        didSet {
            print("State property received location")
        }
    }

    init(wrappedValue: Value) {
        self.value = wrappedValue
    }

    var wrappedValue: Value {
        get {
            return self.value
        }

        nonmutating set {
            print("State value changed to \(newValue)")

            guard let location = self.location else {
                fatalError("Set called on a state property without a location")
            }

            location.setter(newValue)
        }
    }

    mutating func update() {
        if let location = self.location {
            guard let value = location.getter() as? Value else {
                fatalError("Cannot convert new state value from `Any` to `\(Value.self)`")
            }

            print("Update state value to \(value)")
            self.value = value
        }
    }

    /// Creates a new storage node with the state property's
    /// default value in it.
    func createStorageNode() -> StateStorageNode {
        return StateStorageNode(value: self.value)
    }
}

extension State: Equatable where Value: Equatable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.value == rhs.value
    }
}

protocol StateLookup {
    /// Returns the count of state properties in this view.
    func stateCount() -> Int

    /// Sets `location` of the state property at given index.
    mutating func setStateLocation(of index: Int, location: StateLocation?)

    /// Calls the `update` function of the state property at given index.
    mutating func updateState(at index: Int)

    /// Calls the `createStorageNode` function of the state property at given index.
    mutating func createStateStorageNode(of index: Int) -> StateStorageNode
}

protocol TreeNodeEquatable {
    /// Returns `true` if both instances are equal.
    /// The framework's SwiftPM plugin will generate an implementation for every tree node
    /// struct in the project.
    static func equals(lhs: Self, rhs: Self) -> Bool
}

extension TreeNodeEquatable {
    /// Compares two fields of the tree node using `memcmp`.
    /// Fallback implementation if none of the others are available.
    static func fieldEquals<T>(lhs: T, rhs: T) -> Bool {
        // print("> Comparing \(T.self) using memcmp")

        var lhs = lhs
        var rhs = rhs

        let stride = MemoryLayout<T>.stride
        return memcmp(&lhs, &rhs, stride) == 0
    }

    /// Compares two fields of the tree node when their type conforms to `Equatable`.
    static func fieldEquals<T>(lhs: T, rhs: T) -> Bool where T: Equatable {
        // print("> Comparing \(T.self) using Equatable conformance")
        return lhs == rhs
    }

    /// Compares two fields of the tree node when their type conforms to `TreeNodeEquatable`.
    static func fieldEquals<T>(lhs: T, rhs: T) -> Bool where T: TreeNodeEquatable {
        // print("> Comparing \(T.self) using TreeNodeEquatable conformance")
        return T.equals(lhs: lhs, rhs: rhs)
    }

    /// Compares two fields of the tree node when their type conforms to `AnyObject`.
    static func fieldEquals<T>(lhs: T, rhs: T) -> Bool where T: AnyObject {
        return lhs === rhs
    }
}

extension TreeNodeEquatable where Self: Equatable {
    /// Default implementation of `equals` for structs that already conform to `Equatable`.
    static func equals(lhs: Self, rhs: Self) -> Bool {
        // print("> Comparing \(Self.self) using Equatable conformance")
        return lhs == rhs
    }
}

/// Protocol for app tree nodes (app, scenes, views).
protocol TreeNodeMetadata: StateLookup, TreeNodeEquatable {}

protocol View: TreeNodeMetadata {
    associatedtype Body: View

    var body: Body { get }

    /// Reduces this view to one or multiple type-erased views.
    static func makeViews(view: Self) -> [AnyView]

    func tmpOnAppear()
}

extension View {
    func tmpOnAppear() {

    }

    static func makeViews(view: Self) -> [AnyView] {
        return [AnyView(view)]
    }

    func stateCount() -> Int {
        fatalError("Default implementation of `stateCount` called")
    }

    mutating func setStateLocation(of index: Int, location: StateLocation?) {
        fatalError("Default implementation of `setStateLocation` called")
    }

    mutating func updateState(at index: Int) {
        fatalError("Default implementation of `updateState` called")
    }

    mutating func createStateStorageNode(of index: Int) -> StateStorageNode {
        fatalError("Default implementation of `createStateStorageNode` called")
    }
}

@resultBuilder
struct ViewBuilder {
    static func buildBlock() -> NoneView {
        return NoneView()
    }

    static func buildBlock<Content: View>(_ content: Content) -> Content {
        return content
    }

    static func buildIf<Content: View>(_ content: Content?) -> Content? {
        return content
    }

    static func buildBlock<C0: View, C1: View>(_ c0: C0, _ c1: C1) -> TupleView2<C0, C1> {
        return .init(c0, c1)
    }
}

/// Calling `body` on the parent node will produce another GraphNode, which will then
/// be compared to this one to detect any type change.
/// TODO: rename to BodyResult?
struct GraphNode: CustomStringConvertible {
    var mountedViews = [MountedView]()

    init<V: View>(element: V, recursive: Bool) {
        print("Making a new GraphNode for \(V.self)")

        // Prepare as many `MountedView` nodes as necessary, initialize
        // each one with the `makeViews` output
        let views = V.makeViews(view: element)

        for view in views {
            let mountedView = MountedView(view: view)

            // When creating a node for the first time, call `body` directly and
            // create the next node, unless the view is a leaf
            if recursive {
                print("     Checking if \(view.viewType) is a leaf node")
                if !view.isLeaf {
                    mountedView.children = view.body(view.view, true)
                }
            }

            mountedView.setupState()
            self.mountedViews.append(mountedView)
        }
    }

    func printTree(indent: Int = 0) {
        for view in self.mountedViews {
            var res = String(repeating: " ", count: indent)
            res += "- \(view.view.viewType)"
            print(res)

            view.children?.printTree(indent: indent + 4)
        }
    }

    var description: String {
        return "GraphNode(\(self.mountedViews.map({ $0.description} ).joined(separator: ", ")))"
    }
}

/// Stores one state property value.
class StateStorageNode {
    var value: Any

    var location: StateLocation?

    init(value: Any) {
        self.value = value
    }
}

/// Storage for state variables. When a state variable is modified,
/// the setter is executed and changes the value here. Then, `update()` is called
/// on the property before calling `body` on the view.
class StateStorage {
    /// State property index to storage node map.
    var nodes = [Int: StateStorageNode]()
}

/// Must be a class for the state setter / body refresh process: the mounted view needs to escape
/// in the setter closure to be able to update itself (replace any changed child).
class MountedView: CustomStringConvertible {
    /// The type-erased view.
    var view: AnyView

    /// Storage for the view's state properties.
    var stateStorage: StateStorage

    /// The graph node containing this view's children.
    var children: GraphNode?

    /// Creates a new mounted view from given type-erased view.
    init(view: AnyView) {
        self.view = view

        // Create a new state store since we are allocating
        // a new view
        self.stateStorage = StateStorage()
    }

    /// Sets up state values for the mounted view.
    func setupState() {
        print("     Setting up state of \(view.viewType)")

        // Iterate over every state property to set location
        for index in 0..<self.view.stateCount() {
            var storageNode: StateStorageNode

            if let storedNode = self.stateStorage.nodes[index] {
                print("          Updating location and value of state property \(index)")

                storageNode = storedNode

                // Give the state property its new location and call `update`
                // to allow it to update its internal value
                self.view.setStateLocation(of: index, location: storageNode.location)
                self.view.updateState(at: index)
            } else {
                print("          Initializing storage for state property \(index)")
                // Ask the state property to create a new storage node by copying
                // the default value
                storageNode = self.view.createStateStorageNode(of: index)

                // Prepare the location object for the new node
                let getter = {
                    return storageNode.value
                }

                let setter = { (newValue: Any) in
                    print("Setting the new value in the storage node")

                    // Set the new value in the storage node
                    storageNode.value = newValue

                    // Call `update` to update the state property
                    self.view.updateState(at: index)

                    // Call the `body` closure to update children
                    self.refreshBody()
                }

                storageNode.location = StateLocation(
                    setter: setter,
                    getter: getter
                )

                self.stateStorage.nodes[index] = storageNode

                // Give the state property its new location - no need to call `update`
                // since the property already contains the right value
                self.view.setStateLocation(of: index, location: storageNode.location)
            }
        }

        // TMP: Call `tmpOnAppear` at the end of the setup process
        // print("Calling tmpOnAppear")
        self.view.tmpOnAppear(self.view.view)
    }

    /// Calls `body` to produce a new children graph node, then compares the new graph to
    /// the previous one and apply any changes.
    ///
    /// Will not do anything if the view does not have an existing children graph node.
    ///
    /// Do not use for mounting a view for the first time as there is nothing to compare the new
    /// node to. Instead, set `children` to the result of the view `body` closure.
    func refreshBody() {
        // Only refresh body if there is a body in the first place, otherwise it's a leaf
        // node so there is nothing to do
        guard let children = self.children else {
            return
        }

        print("Refreshing body of \(self.view.viewType)")

        // Get the new graph node by calling `body` again
        let newNode = self.view.body(self.view.view, false)

        print("Comparing \(children) to \(newNode)")

        // Iterate over every new node and match them with old nodes in the same order
        for (index, newView) in newNode.mountedViews.enumerated() {
            // Find the corresponding old view: if it out of bounds, insert the new view
            guard let oldView = children.mountedViews[safe: index] else {
                fatalError("Views insertion not implemented yet")
            }

            print("     Comparing \(newView) to \(oldView)")

            // Compare their type to see if it's the same view or a different one
            if newView.view.viewType == oldView.view.viewType {
                // The views are the same type: compare them field by field to see if they need to be
                // updated and if their body needs to be refreshed as well
                print("         Type is identical, comparing field by field")

                if newView.view == oldView.view {
                    // The views are identical: there is nothing to be done
                    // TODO: remove the log, change to != and remove else
                    print("         They are identical")
                } else {
                    print("         They are different")

                    // Replace the old view by the new one in the graph node
                    self.children?.mountedViews[index] = newView

                    // Re-attach the old children graph node so that the new node can call
                    // its body and compare its new children with the previous children
                    self.children?.mountedViews[index].children = oldView.children

                    // TODO: Re-attach the implementation and update it before calling body

                    // Refresh the new view's body
                    self.children?.mountedViews[index].refreshBody()
                }
            } else {
                print("         Type is different, replacing \(oldView.view.viewType) with \(newView.view.viewType)")

                // Otherwise, drop the old view entirely and insert the new one, call body directly
                // TODO: detach the implementation
                newView.children = newView.view.body(newView.view.view, true)
                self.children?.mountedViews[index] = newView
            }
        }

        // TODO: remove any remaining old view (3 views -> 2 views) (reuse code from type is different for dropping a view)
    }

    var description: String {
        return String(String(describing: self.view.viewType).split(separator: "<")[0])
    }
}

/// A type-erased view, used internally to access a view's properties.
///
/// The `Any` parameter for the closures correspond to the view - it can't be captured when the
/// closured are created in `init` so they need to be given when the closures are executed.
///
/// TODO: make body, tmpOnAppear, equals private and make proper functions that give self.view automatically? is it possible?
/// TODO: rename to avoid confusion with the actual AnyView view struct?
struct AnyView: StateLookup, Equatable {
    var view: TreeNodeMetadata
    let viewType: Any.Type

    var body: (_ view: Any, _ recursive: Bool) -> GraphNode = { _, _ in fatalError() }
    var tmpOnAppear: (_ view: Any) -> () = { _ in fatalError() }
    var equals: (_ view: Any, _ other: AnyView) -> Bool = { _, _ in fatalError() }

    let isLeaf: Bool

    init<V>(_ view: V) where V: View {
        self.isLeaf = V.Body.self == Never.self

        self.view = view
        self.viewType = V.self

        self.body = { view, recursive in
            return GraphNode(element: (view as! V).body, recursive: recursive)
        }

        self.tmpOnAppear = { view in
            (view as! V).tmpOnAppear()
        }

        self.equals = { view, other in
            return V.equals(lhs: (view as! V), rhs: (other.view as! V))
        }
    }

    /// Compare two type-erased views field by field.
    static func == (lhs: AnyView, rhs: AnyView) -> Bool {
        if lhs.viewType != rhs.viewType {
            return false
        }

        return lhs.equals(lhs.view, rhs)
    }

    func stateCount() -> Int {
        return self.view.stateCount()
    }

    mutating func updateState(at index: Int) {
        self.view.updateState(at: index)
    }

    mutating func createStateStorageNode(of index: Int) -> StateStorageNode {
        return self.view.createStateStorageNode(of: index)
    }

    mutating func setStateLocation(of index: Int, location: StateLocation?) {
        self.view.setStateLocation(of: index, location: location)
    }
}

// MARK: Built-in views

/// TODO: Rename to TupleView and use an actual tuple if we don't need to compare field-by-field in the end
struct TupleView2<V0: View, V1: View>: View {
    let v0: V0
    let v1: V1

    init(_ v0: V0, _ v1: V1) {
        self.v0 = v0
        self.v1 = v1
    }

    static func makeViews(view: Self) -> [AnyView] {
        return V0.makeViews(view: view.v0) + V1.makeViews(view: view.v1)
    }

    /// GENERATED
    static func equals(lhs: TupleView2<V0, V1>, rhs: TupleView2<V0, V1>) -> Bool {
        guard fieldEquals(lhs: lhs.v0, rhs: rhs.v0) else { return false }
        guard fieldEquals(lhs: lhs.v1, rhs: rhs.v1) else { return false }

        return false
    }
}

extension TupleView2: StateLookup {
    /// GENERATED
    func stateCount() -> Int {
        return 0
    }
}

struct Column<Content>: View, Equatable where Content: View {
    let content: () -> Content

    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    var body: some View {
        return self.content()
    }

    /// A `Column` is never equal to another `Column` to force the framework
    /// to compare its body instead
    static func == (lhs: Self, rhs: Self) -> Bool {
        return false
    }
}

extension Column: StateLookup {
    /// GENERATED
    func stateCount() -> Int {
        return 0
    }
}

struct Row<Content>: View, Equatable where Content: View {
    let content: () -> Content

    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    var body: some View {
        return self.content()
    }

    /// A `Row` is never equal to another `Row` to force the framework
    /// to compare its body instead
    static func == (lhs: Self, rhs: Self) -> Bool {
        return false
    }
}

extension Row: StateLookup {
    /// GENERATED
    func stateCount() -> Int {
        return 0
    }
}

struct Image: View, Equatable {
    typealias Body = Never

    var url: String
}

extension Image: StateLookup {
    /// GENERATED
    func stateCount() -> Int {
        return 0
    }
}

struct NoneView: View, Equatable {
    typealias Body = Never
}

extension NoneView: StateLookup {
    /// GENERATED
    func stateCount() -> Int {
        return 0
    }
}

extension Optional: View, TreeNodeMetadata, TreeNodeEquatable, StateLookup where Wrapped: View {
    typealias Body = Never

    static func makeViews(view: Optional<Wrapped>) -> [AnyView] {
        switch view {
            case let .some(view):
                return Wrapped.makeViews(view: view)
            case .none:
                return NoneView.makeViews(view: NoneView())
        }
    }

    static func equals(lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
            case (.none, .none):
                return true
            case let (.some(lhsView), .some(rhsView)):
                return Wrapped.equals(lhs: lhsView, rhs: rhsView)
            case (.none, .some), (.some, .none):
                return false
        }
    }

    func stateCount() -> Int {
        return 0
    }
}

struct Text: View, Equatable {
    typealias Body = Never

    var text: String

    init(_ text: String) {
        self.text = text
    }
}

extension Text: StateLookup {
    /// GENERATED
    func stateCount() -> Int {
        return 0
    }
}

// MARK: User views

struct Heading1: View, Equatable {
    var text: String

    init(_ text: String) {
        self.text = text
    }

    var body: some View {
        Text(text)
    }
}

extension Heading1: StateLookup {
    /// GENERATED
    func stateCount() -> Int {
        return 0
    }
}

struct Header: View, Equatable {
    var image: String?

    var body: some View {
        Row {
            if let image = image {
                Image(url: image)
            }

            Heading1("Nuclear Reactor Demo")
        }
    }
}

extension Header: StateLookup {
    /// GENERATED
    func stateCount() -> Int {
        return 0
    }
}

var test = true

struct AnotherStatefulView: View, Equatable {
    @State var text = "Content view"

    var body: some View {
        Text(text)
    }
}

extension AnotherStatefulView: StateLookup {
    /// GENERATED
    func stateCount() -> Int {
        return 1
    }

    /// GENERATED
    mutating func setStateLocation(of index: Int, location: StateLocation?) {
        switch index {
            case 0:
                self._text.location = location
            default:
                fatalError("Cannot set state location: index \(index) out of bounds")
        }
    }

    /// GENERATED
    mutating func updateState(at index: Int) {
        switch index {
            case 0:
                self._text.update()
            default:
                fatalError("Cannot update state property: index \(index) out of bounds")
        }
    }

    /// GENERATED
    mutating func createStateStorageNode(of index: Int) -> StateStorageNode {
        switch index {
            case 0:
                return self._text.createStorageNode()
            default:
                fatalError("Cannot create state storage: index \(index) out of bounds")
        }
    }
}

struct Test: View, Equatable {
    var truc: Bool

    var body: some View {
        AnotherStatefulView()
    }

    /// GENERATED
    func stateCount() -> Int {
        return 0
    }
}

struct MainView: View, Equatable {
    @State var hasContent = false

    var body: some View {
        Column {
            Header()

            // Test(truc: hasContent)

            if hasContent {
                AnotherStatefulView()
            }
        }
    }

    func tmpOnAppear() {
        print("MainView tmpOnAppear called")

        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + DispatchTimeInterval.seconds(1)) {
            self.hasContent.toggle()
            // self.hasContent = false
        }
    }
}

extension MainView: StateLookup {
    /// GENERATED
    func stateCount() -> Int {
        return 1
    }

    /// GENERATED
    mutating func setStateLocation(of index: Int, location: StateLocation?) {
        switch index {
            case 0:
                self._hasContent.location = location
            default:
                fatalError("Cannot set state location: index \(index) out of bounds")
        }
    }

    /// GENERATED
    mutating func updateState(at index: Int) {
        switch index {
            case 0:
                self._hasContent.update()
            default:
                fatalError("Cannot update state property: index \(index) out of bounds")
        }
    }

    /// GENERATED
    mutating func createStateStorageNode(of index: Int) -> StateStorageNode {
        switch index {
            case 0:
                return self._hasContent.createStorageNode()
            default:
                fatalError("Cannot create state storage: index \(index) out of bounds")
        }
    }
}

// MARK: Test

let root = MainView()

// Make a graph node
let rootNode = GraphNode(element: root, recursive: true)
print("\n")
rootNode.printTree()

print("--------------------")

dispatchMain()

// let mainView = MainView.makeView(view: MainView())

// print("\(mainView.viewType)") // MainView
// print("     \(mainView.content().viewType)") // Column<Header>
// print("         \(mainView.content().content().viewType)") // Header
// print("             \(mainView.content().content().content().viewType)") // Row<TupleView<(Optional<Image>, Heading1)>>
// print("                 \(mainView.content().content().content().content().viewType)") // TupleView<(Optional<Image>, Heading1)>

// MARK: Never extensions and co.

extension Never: View {
    var body: Never {
        fatalError()
    }
}

/// View extension to provide a `body` property when `Body` is `Never`.
/// Allows only specifying `typealias` for such views.
extension View where Body == Never {
    var body: Never {
        fatalError()
    }
}

extension Collection {
    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

extension MutableCollection {
    subscript(safe index: Index) -> Element? {
        get {
            return indices.contains(index) ? self[index] : nil
        }

        set(newValue) {
            if let newValue = newValue, indices.contains(index) {
                self[index] = newValue
            }
        }
    }
}

/// Uses runtime metadata to get the actual size of a type-erased
/// value.
func size(of value: Any) -> Int {
    guard let metadata = reflect(value) as? TypeMetadata else {
        fatalError("Cannot get type metadata of \(type(of: value))")
    }

    print("Size of \(type(of: value)) = \(metadata.vwt.size)")

    return metadata.vwt.size
}
