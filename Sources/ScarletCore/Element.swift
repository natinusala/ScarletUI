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

/// Input of the `make` method of an element.
public protocol ElementInput<Value> {
    associatedtype Value: Element
}

/// Output of the `make` method of an element.
public protocol ElementOutput<Value> {
    associatedtype Value: Element
}

/// Represents an element of the graph: an app, a scene or a view.
public protocol Element: CustomDebugStringConvertible, IsPodable {
    /// Type of the state tracking node for this element.
    associatedtype Node: ElementNode<Self>

    /// Type of input for this element. Used as a pivot to infer the node and output types,
    /// hence the default value (for user views). Other element types must explicitely
    /// typealias both input and output types to prevent ambiguous `makeNode()` resolution.
    associatedtype Input: ElementInput<Self> = UserMakeInput<Self>
    associatedtype Output: ElementOutput<Self>

    /// Type of target node for this element.
    associatedtype Target: TargetNode

    typealias Context = ElementNodeContext

    /// Makes the node for that element.
    static func makeNode(of element: Self, in parent: (any ElementNode)?, targetPosition: Int, using context: Context) -> Node

    /// Makes the element, usually to get its edges.
    static func make(_ element: Self, input: Input) -> Output

    /// Returns all attributes of the element.
    static func collectAttributes(of element: Self, source: AnyHashable) -> AttributesStash
}

public extension Element {
    /// Creates the target for the view.
    static func makeTarget(of element: Self) -> Target? {
        if Target.self == Never.self {
            return nil
        }

        return Target(displayName: element.displayName)
    }

    /// Default way of collecting attributes: use runtime metadata on the element directly
    /// to gather `@Attribute` property wrappers.
    static func collectAttributes(of element: Self, source: AnyHashable) -> AttributesStash {
        return AttributesStash(
            from: Self.collectAttributesUsingTypeInfo(of: element),
            source: source
        )
    }

    /// Uses runtime metadata to collect all attributes of the given element.
    static func collectAttributesUsingTypeInfo(of element: Self) -> [AttributeTarget: any AttributeSetter] {
        return fatalAttempt(to: "collect attributes of \(Self.self)") {
            let typeInfo = try cachedTypeInfo(of: Self.self)

            var attributes: [AttributeTarget: any AttributeSetter] = [:]

            metadataLogger.debug("Collecting attributes of \(Self.self) using type info")
            for property in typeInfo.properties {
                let value = try property.get(from: element)
                if let attribute = value as? any AttributeSetter {
                    attributes[attribute.target] = attribute
                }
            }

            return attributes
        }
    }
}

public extension Element {
    func makeAnyNode(in parent: (any ElementNode)?, targetPosition: Int, using context: Context) -> any ElementNode {
        return Self.makeNode(of: self, in: parent, targetPosition: targetPosition, using: context)
    }
}

public extension Element {
    var debugDescription: String {
        return "\(Self.self)"
    }

    /// Display name of the element, aka. its type stripped of any generic parameters.
    var displayName: String {
        return Self.displayName
    }

    static var displayName: String {
        return String(describing: Self.self).before(first: "<")
    }
}

@resultBuilder
public struct ElementBuilder {}
