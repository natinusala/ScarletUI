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

import ScarletCore

public struct Padding: AttributeViewModifier {
    @Attribute(\ViewImplementation.padding)
    var padding

    public init(padding: EdgesValues) {
        self.padding = padding
    }
}

public extension View {
    /// Sets the view padding, aka. the space between this view and its children
    func padding(_ padding: Value) -> some View {
        self.modifier(Padding(padding: EdgesValues(top: padding, right: padding, bottom: padding, left: padding)))
    }

    /// Sets the view padding, aka. the space between this view and its children
    func padding(top: Value, right: Value, bottom: Value, left: Value) -> some View {
        self.modifier(Padding(padding: EdgesValues(top: top, right: right, bottom: bottom, left: left)))
    }
}
