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

/// A rectangle filled by a solid color.
public struct Rectangle: View {
    let color: Color

    public init(color: Color) {
        self.color = color
    }

    public var body: some View {
        EmptyView()
            .fill(color: color)
            .grow(1.0)
    }

    public static func accept<Visitor>(visitor: inout Visitor, on element: inout Rectangle) where Rectangle == Visitor.Visited, Visitor : ElementVisitor {}
}
