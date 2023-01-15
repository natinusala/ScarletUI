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
public enum OptionalView<Wrapped>: ComponentModel, View where Wrapped: View {
    public typealias Input = OptionalComponentInput<Self>
    public typealias Output = OptionalComponentOutput<Self, Wrapped>
    public typealias Target = Never

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

    public static func makeNode(of component: Self, in parent: (any ComponentNode)?, targetPosition: Int, using context: Context) -> OptionalComponentNode<Self, Wrapped> {
        return OptionalComponentNode<Self, Wrapped>(making: component, in: parent, targetPosition: targetPosition, using: context)
    }

    public static func make(_ component: Self, input: Input) -> Output {
        return .init(edge: component.optionalValue)
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

public extension ComponentBuilder {
    static func buildOptional<V: View>(_ view: V?) -> OptionalView<V> {
        return .init(from: view)
    }
}
