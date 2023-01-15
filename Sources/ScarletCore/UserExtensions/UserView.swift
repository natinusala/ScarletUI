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

import Needler

public extension View where Input == UserComponentInput<Self>, Output == UserComponentOutput<Self, Body> {
    /// Default implementation of `makeNode()` for user views with a body: make a node with one edge, the body.
    static func makeNode(of component: Self, in parent: (any ComponentNode)?, targetPosition: Int, using context: Context) -> UserComponentNode<Self, Body> {
        return .init(making: component, in: parent, targetPosition: targetPosition, using: context)
    }

    /// Default implementation of `make()` for user views with a body: make the body edge.
    static func make(_ component: Self, input: UserComponentInput<Self>) -> UserComponentOutput<Self, Body> {
        return .init(
            edge: DefaultBodyAccessor.shared.makeBody(of: component)
        )
    }
}

public extension LeafView where Input == LeafViewComponentInput<Self>, Output == LeafViewComponentOutput<Self> {
    /// Default implementation of `makeNode()` for leaves: make a leaf node.
    static func makeNode(of component: Self, in parent: (any ComponentNode)?, targetPosition: Int, using context: Context) -> LeafViewComponentNode<Self> {
        return .init(making: component, in: parent, targetPosition: targetPosition, using: context)
    }

    /// Default implementation of `make()` for leaves: make an empty edge.
    static func make(_ component: Self, input: LeafViewComponentInput<Self>) -> LeafViewComponentOutput<Self> {
        return .init()
    }
}

public extension StatelessLeafView where Input == StatelessLeafViewComponentInput<Self>, Output == StatelessLeafViewComponentOutput<Self> {
    /// Default implementation of `makeNode()` for leaves: make a leaf node.
    static func makeNode(of component: Self, in parent: (any ComponentNode)?, targetPosition: Int, using context: Context) -> StatelessLeafViewComponentNode<Self> {
        return .init(making: component, in: parent, targetPosition: targetPosition, using: context)
    }

    /// Default implementation of `make()` for leaves: make an empty edge.
    static func make(_ component: Self, input: StatelessLeafViewComponentInput<Self>) -> StatelessLeafViewComponentOutput<Self> {
        return .init()
    }
}
