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
    let kind: ImplementationKind
    public let displayName: String
    var attributes = Attributes()
    var children: [ViewImpl] = []

    private var ignoreChildren = false

    public static func == (lhs: ViewImpl, rhs: ViewImpl) -> Bool {
        let childrenEqual = lhs.ignoreChildren || rhs.ignoreChildren || lhs.children == rhs.children

        return lhs.kind == rhs.kind
            && lhs.displayName == rhs.displayName 
            && lhs.attributes == rhs.attributes 
            && childrenEqual
    }

    struct Attributes: Equatable {
        var id: String = ""
    }

    /// Initializer used to create the expected implementation tree.
    convenience init(
        _ displayName: String,
        id: String = "",
        @ViewImplChildrenBuilder children: () -> [ViewImpl] = { [] }
    ) {
        self.init(kind: .view, displayName: displayName)

        self.attributes.id = id

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
        ViewImpl("\(self.displayName)", \(self.attributes)) \(children)
        """
    }
}

extension View {
    public typealias Implementation = ViewImpl
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
