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

public extension View {
    /// Default implementation of `makeNode()` for user views with a body: make a node with one edge, the body.
    static func makeNode(of element: Self, in parent: (any ElementNode)?, implementationPosition: Int) -> UserElementNode<Self, Body> where Input == UserMakeInput<Self> {
        return .init(making: element, in: parent, implementationPosition: implementationPosition)
    }

    /// Default implementation of `make()` for user views with a body: make the body edge.
    static func make(_ element: Self, input: UserMakeInput<Self>) -> UserMakeOutput<Self, Body> {
        return .init(
            edge: element.body
        )
    }
}

public extension LeafView {
    /// Default implementation of `makeNode()` for user views with no body: make a leaf node.
    static func makeNode(of element: Self, in parent: (any ElementNode)?, implementationPosition: Int) -> LeafElementNode<Self> where Input == LeafMakeInput<Self> {
        return .init(making: element, in: parent, implementationPosition: implementationPosition)
    }

    /// Default implementation of `make()` for user views with no body: make an empty edge.
    static func make(_ element: Self, input: LeafMakeInput<Self>) -> LeafMakeOutput<Self> {
        return .init()
    }
}
