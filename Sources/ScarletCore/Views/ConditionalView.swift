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

/// A view with an edge that can be one type or the other, depending on the path the
/// condition takes ("first" or "second").
public enum ConditionalView<First, Second>: View where First: View, Second: View {
    public typealias Input = ConditionalMakeInput<Self>
    public typealias Output = ConditionalMakeOutput<Self, First, Second>
    public typealias Target = Never

    case first(First)
    case second(Second)

    public static func makeNode(of element: Self, in parent: (any ElementNode)?, targetPosition: Int, using context: Context) -> ConditionalElementNode<Self, First, Second> {
        return ConditionalElementNode<Self, First, Second>(making: element, in: parent, targetPosition: targetPosition, using: context)
    }

    public static func make(_ element: Self, input: Input) -> Output {
        switch element {
            case .first(let first):
                return .first(first)
            case .second(let second):
                return .second(second)
        }
    }
}

public extension ElementBuilder {
    static func buildEither<First: View, Second: View>(first: First) -> ConditionalView<First, Second> {
        return .first(first)
    }

    static func buildEither<First: View, Second: View>(second: Second) -> ConditionalView<First, Second> {
        return .second(second)
    }
}
