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
    enum Storage {
        case first
        case second
    }

    case first(FirstContent)
    case second(SecondContent)

    public typealias Body = Never
    public typealias Implementation = Never

    var contentType: Any.Type {
        switch self {
            case .first:
                return FirstContent.self
            case .second:
                return SecondContent.self
        }
    }

    var storageValue: Storage {
        switch self {
        case .first:
            return .first
        case .second:
            return .second
        }
    }

    public static func make(view: Self?, input: MakeInput) -> MakeOutput {
        let output: ElementOutput?
        let edges: [MakeOutput.StaticEdge]
        let implementationCount: Int

        // If we have a view, evaluate it normally
        // If not, consider the view unchanged and
        // use our storage to know where to redirect the edge `make` call
        if let view = view {
            output = ElementOutput(storage: view.storageValue, attributes: view.collectAttributes())

            // If the content storage belongs to a different type than the expected one,
            // discard the node (it changed from `first` to `second` or `second` to `first`)
            var contentStorage = input.storage?.edges.asStatic[0]
            if let storage = contentStorage, storage.elementType != view.contentType {
                contentStorage = nil
            }

            let input = MakeInput(storage: contentStorage, implementationPosition: input.implementationPosition)

            switch view {
                case let .first(first):
                    let output = FirstContent.make(view: first, input: input)
                    implementationCount = output.implementationCount
                    edges = [.some(output)]
                case let .second(second):
                    let output = SecondContent.make(view: second, input: input)
                    implementationCount = output.implementationCount
                    edges = [.some(output)]
            }
        } else if let storage = input.storage, let storageValue = storage.value as? Storage {
            output = nil

            let contentStorage = storage.edges.asStatic[0]
            let input = MakeInput(storage: contentStorage, implementationPosition: input.implementationPosition)

            switch storageValue {
                case .first:
                    let output = FirstContent.make(view: nil, input: input)
                    implementationCount = output.implementationCount
                    edges = [.some(output)]
                case .second:
                    let output = SecondContent.make(view: nil, input: input)
                    implementationCount = output.implementationCount
                    edges = [.some(output)]
            }
        } else {
            fatalError("Cannot make a `ConditionalView` without a view or a storage node")
        }

        return Self.output(
            node: output,
            staticEdges: edges,
            implementationPosition: input.implementationPosition,
            implementationCount: implementationCount,
            accessor: view?.accessor
        )
    }

    /// Conditionals have one edge: its content, either first or second.
    public static var staticEdgesCount: Int {
        return 1
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
