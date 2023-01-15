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

extension ModifiedContent: ComponentModel, View, CustomDebugStringConvertible, IsPodable where Content: View, Modifier: ViewModifier {
    public typealias Target = Never

    public typealias Input = ModifiedViewComponentInput<Content, Modifier>
    public typealias Output = ModifiedViewComponentOutput<Content, Modifier>

    public static func makeNode(of component: Self, in parent: (any ComponentNode)?, targetPosition: Int, using context: Context) -> ModifiedViewComponentNode<Content, Modifier> {
        return ModifiedViewComponentNode(making: component, in: parent, targetPosition: targetPosition, using: context)
    }

    /// Makes the component, usually to get its edges.
    public static func make(_ component: Self, input: Input) -> Output {
        return .init(
            content: component.content,
            modifier: component.modifier
        )
    }
}
