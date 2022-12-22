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
import XCTest

@testable import ScarletCore

private let logger = Logger(label: "ScarletCoreIntegrationTests.ViewImpl")

private func log(_ message: @autoclosure () -> Logger.Message) {
    let loggingEnv = "SCARLET_TESTS_LOG"

    if ProcessInfo.processInfo.environment[loggingEnv] == "1" {
        logger.info(message())
    }
}

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
                log("'id' attribute update: \(String(describing: id)) -> \(String(describing: newValue))")
                self.updated.insert(\.id)
                self.updatesCount += 1
            }
        }

        var fill: Color? {
            willSet {
                log("'fill' attribute update: \(String(describing: fill)) -> \(String(describing: newValue))")
                self.updated.insert(\.fill)
                self.updatesCount += 1
            }
        }

        var grow: Float? {
            willSet {
                log("'grow' attribute update: \(String(describing: grow)) -> \(String(describing: newValue))")
                self.updated.insert(\.grow)
                self.updatesCount += 1
            }
        }

        var tags = AttributeList<String>() {
            willSet {
                log("'tags' attribute update: \(String(describing: tags)) -> \(String(describing: newValue))")
                self.updated.insert(\.tags)
                self.updatesCount += 1
            }
        }

        var flags = AttributeList<Flag>() {
            willSet {
                log("'flags' attribute update: \(String(describing: flags)) -> \(String(describing: newValue))")
                self.updated.insert(\.flags)
                self.updatesCount += 1
            }
        }

        /// Redefined equality check to ignore ``updated`` and ``updatesCount``.
        static func == (lhs: Self, rhs: Self) -> Bool {
            return lhs.id == rhs.id && lhs.fill == rhs.fill && lhs.grow == rhs.grow && lhs.tags == rhs.tags && lhs.flags == rhs.flags
        }

        var updated: Set<PartialKeyPath<Self>> = []
        var updatesCount = 0

        /// Resets the updated flag for all attributes.
        mutating func reset() {
            self.updated = []
            self.updatesCount = 0
        }

        /// Returns `true` if the given attribute has changed since the last ``reset()`` call, `false` otherwise.
        func changed(_ attribute: PartialKeyPath<Self>) -> Bool {
            return self.updated.contains(attribute)
        }

        /// Returns `true` if any attribute has changed since the last ``reset()`` call, `false` otherwise.
        var anyChanged: Bool {
            return !self.updated.isEmpty
        }

        var description: String {
            return Mirror(reflecting: self).children.compactMap { label, value in
                let label = label ?? "nil"
                guard !label.contains("updated") else { return nil }
                guard !label.contains("updatesCount") else { return nil }

                let valueStr = removeOptional("\(value)")
                return "\(label)=\"\(valueStr)\""
            }.joined(separator: " ")
        }
    }

    public let displayName: String

    var attributes = Attributes()

    var anyAttributeChanged: Bool {
        return self.attributes.anyChanged
    }

    func attributeChanged(_ attribute: PartialKeyPath<Attributes>) -> Bool {
        return self.attributes.changed(attribute)
    }

    var attributesUpdatesCount: Int {
        return self.attributes.updatesCount
    }

    /// Resets testing data for the view and all of its children recursively.
    open func reset() {
        self.attributes.reset()

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
        tags: [String] = [],
        flags: [Flag] = [],
        @ViewImplChildrenBuilder children: () -> [ViewImpl] = { [] }
    ) {
        self.init(displayName: displayName)

        self.attributes.id = id
        self.attributes.fill = fill
        self.attributes.grow = grow
        self.attributes.tags = .init(uniqueKeysWithValues: tags.map { (UUID(), $0) })
        self.attributes.flags = .init(uniqueKeysWithValues: flags.map { (UUID(), $0) })

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

    func `as`<NewType: ViewImpl>(_ type: NewType.Type) -> NewType {
        return self as! NewType
    }

    func findFirst<NewType: ViewImpl>(_ type: NewType.Type) -> NewType {
        func inner(_ impl: ViewImpl) -> NewType? {
            if let instance = impl as? NewType {
                return instance
            }

            for child in impl.children {
                if let instance = inner(child) {
                    return instance
                }
            }

            return nil
        }

        guard let found = inner(self) else {
            fatalError("Did not find any view with type '\(NewType.self)'")
        }

        return found
    }

    func findAll<NewType: ViewImpl>(_ type: NewType.Type, expectedCount: Int) -> [NewType] {
        func inner(_ impl: ViewImpl) -> [NewType] {
            if let instance = impl as? NewType {
                return [instance]
            }

            return impl.children.map {
                inner($0)
            }.chained()
        }

        let found = inner(self)

        guard found.count == expectedCount else {
            XCTFail("Expected to find \(expectedCount) \(NewType.self), found \(found.count)")
            return []
        }

        return found
    }

    func allChildren() -> [ViewImpl] {
        return self.children + self.children.map { $0.allChildren() }.chained()
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

enum Flag {
    case focusable
    case clickable
    case accessible
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
