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

public protocol MakeInput<Value> {
    associatedtype Value: Element
}

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

    associatedtype Implementation: ImplementationNode

    typealias Context = ElementNodeContext

    /// Makes the node for that element.
    static func makeNode(of element: Self, in parent: (any ElementNode)?, implementationPosition: Int, using context: Context) -> Node

    /// Makes the element, usually to get its edges.
    static func make(_ element: Self, input: Input) -> Output

    /// Makes the implementation node for this element.
    static func makeImplementation(of element: Self) -> Implementation?
}

public extension Element where Implementation == Never {
    static func makeImplementation(of element: Self) -> Never? {
        return nil
    }
}

public extension Element {
    var debugDescription: String {
        return "\(Self.self)"
    }
}

@resultBuilder
public struct ElementBuilder {}
