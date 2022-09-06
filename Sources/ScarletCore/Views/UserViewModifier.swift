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

public extension ViewModifier where Body: View, Input == UserViewModifierMakeInput<Self>, Output == UserViewModifierMakeOutput<Self, Body> {
    static func makeNode(of element: Self, in parent: (any ElementNode)?, implementationPosition: Int, using context: Context) -> UserViewModifierElementNode<Self, Body> {
        return .init(making: element, in: parent, implementationPosition: implementationPosition, using: context)
    }

    static func make(_ element: Self, input: UserViewModifierMakeInput<Self>) -> UserViewModifierMakeOutput<Self, Body> {
        return .init(
            edge: element.body(content: input.content)
        )
    }
}
