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

/// A view that is either the "first one" or the "second one".
public enum ConditionalView<FirstContent, SecondContent>: View where FirstContent: View, SecondContent: View {
    case first(FirstContent)
    case second(SecondContent)

    public typealias Body = Never
    public typealias Implementation = Never

    public static func make(view: Self, input: MakeInput) -> MakeOutput {
        let output = ElementOutput(type: Self.self, storage: nil, implementationProxy: view.implementationProxy)
        let edges: [MakeOutput?]

        switch view {
            case let .first(first):
                let firstInput = MakeInput(storage: input.storage?.edges[0])
                edges = [FirstContent.make(view: first, input: firstInput), nil]
            case let .second(second):
                let secondInput = MakeInput(storage: input.storage?.edges[1])
                edges = [nil, SecondContent.make(view: second, input: secondInput)]
        }

        return .changed(new: .init(node: output, staticEdges: edges))
    }

    /// Conditionals have two edges: the first content and the second content. Only one of them has a value at a time.
    public static func staticEdgesCount() -> Int {
        return 2
    }
}

public extension ViewBuilder {
    static func buildEither<FirstContent, SecondContent>(
        first content: FirstContent
    ) -> ConditionalView<FirstContent, SecondContent> where FirstContent: View, SecondContent: View {
        return .first(content)
    }

    static func buildEither<FirstContent, SecondContent>(
        second content: SecondContent
    ) -> ConditionalView<FirstContent, SecondContent> where FirstContent: View, SecondContent: View {
        return .second(content)
    }
}
