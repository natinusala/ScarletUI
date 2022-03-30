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

/// A view modifier serves two purposes:
///     - set a view attribute
///     - wrap a view in another (modified or not) view (unimplemented)
protocol ViewModifier {
    typealias Content = ViewModifierContent<Self>

    associatedtype Body: View

    func body(content: Content) -> Body
}

extension ViewModifier {
    /// Default implementation of `body` for a view modifier: returns the unmodified view.
    func body(content: Content) -> some View {
        return content
    }
}

/// A modified view, input to a view modifier `body` method.
///
/// This is a placeholder struct that's replaced by `ModifiedContent` to inject
/// the actual modified view instead.
struct ViewModifierContent<Modifier>: View where Modifier: ViewModifier {
    typealias Body = Never
}

extension ModifiedContent: View where Modifier: ViewModifier, Content: View {
    typealias Body = Never

    static func makeViews(view: Self, previous: Self?) -> [ElementOperation] {
        // Call `makeViews` on the modifier and iterate over all operations
        // to replace every `ViewModifierContent` occurence by our content view
        let operations = Modifier.makeViews(modifier: view.modifier, previous: previous?.modifier)
    }
}

extension View {
    /// Returns a modified version of this view, with the given modifier applied.
    func modifier<Modifier>(_ modifier: Modifier) -> ModifiedContent<Self, Modifier> where Modifier: ViewModifier {
        return ModifiedContent<Self, Modifier>(content: self, modifier: modifier)
    }
}
