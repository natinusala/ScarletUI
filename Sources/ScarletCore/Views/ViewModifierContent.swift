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

/// Placeholder for view modifiers content. Contains one edge: the actual content.
public struct ViewModifierContent<Modifier>: View where Modifier: ViewModifier {
    public typealias Implementation = Never

    public typealias Input = ViewModifierContentMakeInput<Self>
    public typealias Output = ViewModifierContentMakeOutput<Self>

    public static func makeNode(of element: Self, in parent: (any ElementNode)?, implementationPosition: Int, using context: Context) -> ViewModifierContentElementNode<Self> {
        return ViewModifierContentElementNode<Self>(making: element, in: parent, implementationPosition: implementationPosition, using: context)
    }

    public static func make(_ element: Self, input: Input) -> Output {
        return Output()
    }
}

/// Context given to a ``ViewModifierContent`` by its parent ``ModifiedContent``. Contains
/// the type-erased content element to check and update.
/// If the content is `nil` it means it didn't change, however it's still updated in
/// case its edges are different (depending on context).
struct ViewModifierContentContext {
    let content: (any Element)?
}
