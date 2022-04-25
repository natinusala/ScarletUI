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

public struct FillModifier: AttributeViewModifier {
    @Attribute(\ViewImplementation.fill)
    var fill

    public init(_ fill: Fill) {
        self.fill = fill
    }
}

public extension View {
    /// Sets the view fill, aka. the color or gradient of the view's background
    func fill(_ fill: Fill) -> some View {
        self.modifier(FillModifier(fill))
    }
}

/// A view fill color or gradient.
public enum Fill {
    case none
    case color(Color)

    /// Creates a paint for the fill. The created paint
    /// must fit inside the given rect.
    func createPaint(inside rect: Rect) -> Paint? {
        switch self {
            case .none:
                return nil
            case let .color(color):
                return Paint(color: color)
        }
    }
}
