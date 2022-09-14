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

// TODO: Rename to ElementInput and all implementations to XXXInput
public protocol MakeInput<Value> {
    associatedtype Value: Element
}

// TODO: Rename to ElementOutput and all implementations to XXXOutput
public protocol MakeOutput<Value> {
    associatedtype Value: Element
}

/// Represents an element of the graph: an app, a scene or a view.
public protocol Element: CustomDebugStringConvertible {
    /// Type of the state tracking node for this element.
    associatedtype Node: ElementNode<Self>

    /// Type of input for this element. Used as a pivot to infer the node and output types,
    /// hence the default value (for user views). Other element types must explicitely
    /// typealias both input and output types to prevent ambiguous `makeNode()` resolution.
    associatedtype Input: MakeInput<Self> = UserMakeInput<Self>
    associatedtype Output: MakeOutput<Self>

    /// Type of implementation node for this element.
    associatedtype Implementation: ImplementationNode

    typealias Context = ElementNodeContext

    /// Makes the node for that element.
    static func makeNode(of element: Self, in parent: (any ElementNode)?, implementationPosition: Int, using context: Context) -> Node

    /// Makes the element, usually to get its edges.
    static func make(_ element: Self, input: Input) -> Output

    /// Returns all attributes of the element.
    static func collectAttributes(of element: Self) -> AttributesStash
}

public extension Element {
    /// Creates the implementation for the view.
    static func makeImplementation(of element: Self) -> Implementation? {
        if Implementation.self == Never.self {
            return nil
        }

        return Implementation(displayName: element.displayName)
    }

    /// Default way of collecting attributes: use a Mirror on the element directly
    /// to gather `@Attribute` property wrappers.
    static func collectAttributes(of element: Self) -> AttributesStash {
        return Self.collectAttributesUsingMirror(of: element)
    }

    /// Uses a Mirror to collect all attributes of the given element.
    static func collectAttributesUsingMirror(of element: Self) -> AttributesStash {
        let mirror = Mirror(reflecting: element)

        var attributes: AttributesStash = [:]

        for child in mirror.children {
            if let attribute = child.value as? any AttributeSetter {
                attributes[attribute.target] = attribute
            }
        }

        return attributes
    }
}

public extension Element {
    func makeAnyNode(in parent: (any ElementNode)?, implementationPosition: Int, using context: Context) -> any ElementNode {
        return Self.makeNode(of: self, in: parent, implementationPosition: implementationPosition, using: context)
    }
}

public extension Element {
    var debugDescription: String {
        return "\(Self.self)"
    }

    /// Display name of the element, aka. its type stripped of any generic parameters.
    var displayName: String {
        return String(describing: Self.self).before(first: "<")
    }
}

@resultBuilder
public struct ElementBuilder {}
