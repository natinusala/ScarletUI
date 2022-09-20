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

extension ModifiedContent: Element, View, CustomDebugStringConvertible, IsPodable where Content: View, Modifier: ViewModifier {
    public typealias Implementation = Never

    public typealias Input = ModifiedViewMakeInput<Content, Modifier>
    public typealias Output = ModifiedViewMakeOutput<Content, Modifier>

    public static func makeNode(of element: Self, in parent: (any ElementNode)?, implementationPosition: Int, using context: Context) -> ModifiedViewElementNode<Content, Modifier> {
        return ModifiedViewElementNode(making: element, in: parent, implementationPosition: implementationPosition, using: context)
    }

    /// Makes the element, usually to get its edges.
    public static func make(_ element: Self, input: Input) -> Output {
        return .init(
            content: element.content,
            modifier: element.modifier
        )
    }
}
