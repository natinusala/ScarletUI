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

public extension View where Input == UserMakeInput<Self>, Output == UserMakeOutput<Self, Body> {
    /// Default implementation of `makeNode()` for user views with a body: make a node with one edge, the body.
    static func makeNode(of element: Self, in parent: (any ElementNode)?, implementationPosition: Int, using context: Context) -> UserElementNode<Self, Body> {
        return .init(making: element, in: parent, implementationPosition: implementationPosition, using: context)
    }

    /// Default implementation of `make()` for user views with a body: make the body edge.
    static func make(_ element: Self, input: UserMakeInput<Self>) -> UserMakeOutput<Self, Body> {
        return .init(
            edge: Dependencies.bodyAccessor.makeBody(of: element)
        )
    }
}

public extension LeafView where Input == LeafViewMakeInput<Self>, Output == LeafViewMakeOutput<Self> {
    /// Default implementation of `makeNode()` for leaves: make a leaf node.
    static func makeNode(of element: Self, in parent: (any ElementNode)?, implementationPosition: Int, using context: Context) -> LeafViewElementNode<Self> {
        return .init(making: element, in: parent, implementationPosition: implementationPosition, using: context)
    }

    /// Default implementation of `make()` for leaves: make an empty edge.
    static func make(_ element: Self, input: LeafViewMakeInput<Self>) -> LeafViewMakeOutput<Self> {
        return .init()
    }
}
