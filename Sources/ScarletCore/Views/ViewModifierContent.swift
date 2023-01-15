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
    public typealias Target = Never

    public typealias Input = ViewModifierContentComponentInput<Self>
    public typealias Output = ViewModifierContentComponentOutput<Self>

    public static func makeNode(of component: Self, in parent: (any ComponentNode)?, targetPosition: Int, using context: Context) -> ViewModifierContentComponentNode<Self> {
        return ViewModifierContentComponentNode<Self>(making: component, in: parent, targetPosition: targetPosition, using: context)
    }

    public static func make(_ component: Self, input: Input) -> Output {
        return Output()
    }
}

/// Context given to a ``ViewModifierContent`` by its parent ``ModifiedContent``. Contains
/// the type-erased content component to check and update.
/// If the content is `nil` it means it didn't change, however it's still updated in
/// case its edges are different (depending on context).
struct ViewModifierContentContext {
    let content: (any ComponentModel)?
}
