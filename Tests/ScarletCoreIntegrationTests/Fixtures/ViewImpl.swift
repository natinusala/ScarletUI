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

@testable import ScarletCore

public class ViewImpl: ImplementationNode, Equatable, CustomStringConvertible {
    struct Attributes: Equatable {
        var id: String?
        var fill: Color?
        var grow: Float?
    }

    let kind: ImplementationKind
    public let displayName: String
    var attributes = Attributes()
    var children: [ViewImpl] = []

    private var ignoreChildren = false

    public static func == (lhs: ViewImpl, rhs: ViewImpl) -> Bool {
        let childrenEqual = lhs.ignoreChildren || rhs.ignoreChildren || lhs.children == rhs.children

        return type(of: lhs) == type(of: rhs)
            && lhs.kind == rhs.kind
            && lhs.displayName == rhs.displayName
            && lhs.attributes == rhs.attributes
            && lhs.equals(to: rhs)
            && childrenEqual
    }

    /// Test signals handlers.
    // var signalHandlers = AttributeList<(signal: any TestSignal, closure: () -> ())>()

    // func signal(_ signal: any TestSignal) {
    //     for handler in self.signalHandlers {
    //         if handler.signal.rawValue == signal.rawValue {
    //             handler.closure()
    //         }
    //     }

    //     for child in self.children {
    //         child.signal(signal)
    //     }
    // }

    /// Used by custom implementations to compare their custom attributes.
    open func equals(to other: ViewImpl) -> Bool {
        return true
    }

    /// Initializer used to create the expected implementation tree.
    convenience init(
        _ displayName: String,
        id: String? = nil,
        fill: Color? = nil,
        grow: Float? = nil,
        @ViewImplChildrenBuilder children: () -> [ViewImpl] = { [] }
    ) {
        self.init(kind: .view, displayName: displayName)

        self.attributes.id = id
        self.attributes.fill = fill
        self.attributes.grow = grow

        self.children = children()
    }

    /// Initializer used by ScarletCore.
    public required init(kind: ImplementationKind, displayName: String) {
        self.kind = kind
        self.displayName = displayName
    }

    public func anyChildren() -> ViewImpl {
        self.ignoreChildren = true
        return self
    }

    public func attributesDidSet() {}

    public func insertChild(_ child: ScarletCore.ImplementationNode, at position: Int) {
        self.children.insert(child as! ViewImpl, at: position)
    }

    public func removeChild(at position: Int) {
        self.children.remove(at: position)
    }

    public var description: String {
        let children: String
        if self.children.isEmpty {
            children = ""
        } else {
            children = """
            {
                \(self.children.map { "\($0)" }.joined(separator: " "))
            }
            """
        }
        return """
        \(Self.self)("\(self.displayName)", \(self.attributes)) \(children)
        """
    }
}

extension View {
    static func makeImplementation(of element: Self) -> ViewImpl? {
        return ViewImpl(kind: .view, displayName: element.displayName)
    }
}

@resultBuilder
struct ViewImplChildrenBuilder {
    static func buildBlock(_ children: ViewImpl...) -> [ViewImpl] {
        return children
    }

    static func buildBlock() -> [ViewImpl] {
        return []
    }
}
