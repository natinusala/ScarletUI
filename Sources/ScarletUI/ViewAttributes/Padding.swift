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

public extension View {
    /// Sets the view padding, aka. the space between this view and its children.
    /// Note: percentage always uses parent's width, even for top and bottom edges.
    func padding(_ padding: LayoutValue) -> some View {
        return self.attributed(Attribute(\_ViewImplementation.padding, value: EdgesLayoutValues(top: padding, right: padding, bottom: padding, left: padding)))
    }

    /// Sets the view padding, aka. the space between this view and its children.
    /// Note: percentage always uses parent's width, even for top and bottom edges.
    func padding(top: LayoutValue, right: LayoutValue, bottom: LayoutValue, left: LayoutValue) -> some View {
        return self.attributed(Attribute(\_ViewImplementation.padding, value: EdgesLayoutValues(top: top, right: right, bottom: bottom, left: left)))
    }
}
