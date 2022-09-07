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

/// A view with an edge that can be either present or not.
/// Does not use the built-in `Optional` enum to avoid using built-in optional features (don't treat
/// optional views as true optionals).
public enum OptionalView<Wrapped>: Element, View where Wrapped: View {
    case some(wrapped: Wrapped)
    case none

    init(from optional: Wrapped?) {
        switch optional {
            case .some(let wrapped):
                self = .some(wrapped: wrapped)
            case .none:
                self = .none
        }
    }

    public typealias Input = OptionalMakeInput<Self>
    public typealias Output = OptionalMakeOutput<Self, Wrapped>

    public static func makeNode(of element: Self, in parent: (any ElementNode)?, implementationPosition: Int, using context: Context) -> OptionalElementNode<Self, Wrapped> {
        return OptionalElementNode<Self, Wrapped>(making: element, in: parent, implementationPosition: implementationPosition, using: context)
    }

    public static func make(_ element: Self, input: Input) -> Output {
        return .init(edge: element.optionalValue)
    }

    var optionalValue: Wrapped? {
        switch self {
            case .some(let wrapped):
                return wrapped
            case .none:
                return nil
        }
    }
}

public extension ElementBuilder {
    static func buildOptional<V: View>(_ view: V?) -> OptionalView<V> {
        return .init(from: view)
    }
}
