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

public extension Scene where Input == UserMakeInput<Self>, Output == UserMakeOutput<Self, Body> {
    /// Default implementation of `makeNode()` for user scenes with a body: make a node with one edge, the body.
    static func makeNode(of element: Self, in parent: (any ElementNode)?, implementationPosition: Int, using context: Context) -> UserElementNode<Self, Body> {
        return .init(making: element, in: parent, implementationPosition: implementationPosition, using: context)
    }

    /// Default implementation of `make()` for user scenes with a body: make the body edge.
    static func make(_ element: Self, input: UserMakeInput<Self>) -> UserMakeOutput<Self, Body> {
        return .init(
            edge: DefaultBodyAccessor.shared.makeBody(of: element)
        )
    }
}

public extension LeafScene where Input == UserMakeInput<Self>, Output == UserMakeOutput<Self, Content> {
    static func makeNode(of element: Self, in parent: (any ElementNode)?, implementationPosition: Int, using context: Context) -> LeafSceneElementNode<Self, Content> {
        return .init(making: element, in: parent, implementationPosition: implementationPosition, using: context)
    }

    static func make(_ element: Self, input: UserMakeInput<Self>) -> UserMakeOutput<Self, Content> {
        return .init(
            edge: element.content
        )
    }
}

public extension StatelessLeafScene where Input == UserMakeInput<Self>, Output == UserMakeOutput<Self, Content> {
    static func makeNode(of element: Self, in parent: (any ElementNode)?, implementationPosition: Int, using context: Context) -> StatelessLeafSceneElementNode<Self, Content> {
        return .init(making: element, in: parent, implementationPosition: implementationPosition, using: context)
    }

    static func make(_ element: Self, input: UserMakeInput<Self>) -> UserMakeOutput<Self, Content> {
        return .init(
            edge: element.content
        )
    }
}
