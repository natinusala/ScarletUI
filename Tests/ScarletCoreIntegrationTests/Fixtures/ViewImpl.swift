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

import _StringProcessing
import RegexBuilder
import Logging

@testable import ScarletCore

private let logger = Logger(label: "ScarletCoreIntegrationTests.ViewImpl")

private func removeOptional(_ string: String) -> String {
    let match = string.firstMatch(of: Regex {
        "Optional("
            Capture {
                OneOrMore(.any)
            }
        ")"
    })

    guard let match else {
        return string
    }

    return String(match.1)
}

public class ViewImpl: ImplementationNode, Equatable, CustomStringConvertible {
    struct Attributes: Equatable, CustomStringConvertible {
        var id: String? {
            willSet {
                logger.info("'id' attribute update: \(String(describing: id)) -> \(String(describing: newValue))")
            }
        }

        var fill: Color? {
            willSet {
                logger.info("'fill' attribute update: \(String(describing: fill)) -> \(String(describing: newValue))")
            }
        }

        var grow: Float? {
            willSet {
                logger.info("'grow' attribute update: \(String(describing: grow)) -> \(String(describing: newValue))")
            }
        }

        var description: String {
            return Mirror(reflecting: self).children.map { label, value in
                let valueStr = removeOptional("\(value)")
                return "\(label ?? "nil")=\"\(valueStr)\""
            }.joined(separator: " ")
        }
    }

    public let displayName: String

    var attributesChanged = false
    var attributes = Attributes() {
        didSet {
            self.attributesChanged = true
        }
    }

    /// Resets testing data for the view and all of its children recursively.
    func reset() {
        self.attributesChanged = false

        for child in self.children {
            child.reset()
        }
    }

    var children: [ViewImpl] = []

    private var ignoreChildren = false

    public static func == (lhs: ViewImpl, rhs: ViewImpl) -> Bool {
        let childrenEqual = lhs.ignoreChildren || rhs.ignoreChildren || lhs.children == rhs.children

        return type(of: lhs) == type(of: rhs)
            && lhs.displayName == rhs.displayName
            && lhs.attributes == rhs.attributes
            && lhs.equals(to: rhs)
            && childrenEqual
    }

    /// Test signals handlers.
    var signalHandlers = AttributeList<(signal: any TestSignal, closure: () -> ())>()

    func signal(_ signal: any TestSignal) {
        for handler in self.signalHandlers {
            if handler.signal.rawValue == signal.rawValue {
                handler.closure()
            }
        }

        for child in self.children {
            child.signal(signal)
        }
    }

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
        self.init(displayName: displayName)

        self.attributes.id = id
        self.attributes.fill = fill
        self.attributes.grow = grow

        self.children = children()
    }

    /// Initializer used by ScarletCore.
    public required init(displayName: String) {
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

    open var customAttributesDebugDescription: String {
        return ""
    }

    public var description: String {
        let children: String
        if self.children.isEmpty {
            children = ""
        } else {
            children = self.children.map { "\($0)" }.joined(separator: " ")
        }
        return """
        <\(self.displayName) \(self.attributes) \(self.customAttributesDebugDescription)>\(children)</\(self.displayName)>
        """
    }
}

extension View {
    public typealias Implementation = ViewImpl
}

extension ViewModifier {
    public typealias Implementation = Never
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
