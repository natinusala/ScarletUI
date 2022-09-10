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

public protocol ViewModifier: Element {
    associatedtype Body: View

    typealias Content = ViewModifierContent<Self>

    @ElementBuilder func body(content: Content) -> Body
}

public struct ModifiedContent<Content, Modifier> {
    let content: Content
    let modifier: Modifier
}

public extension View {
    func modifier<Modifier: ViewModifier>(_ modifier: Modifier) -> some View {
        return ModifiedContent<Self, Modifier>(content: self, modifier: modifier)
    }
}
