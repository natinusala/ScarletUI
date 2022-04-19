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

/// An optional view.
extension Optional: View, Accessor where Wrapped: View {
    enum Storage {
        case none
        case some
    }

    var storageValue: Storage {
        switch self {
            case .none:
                return .none
            case .some:
                return .some
        }
    }

    public typealias Body = Never
    public typealias Implementation = Never

    public static func make(view: Self?, input: MakeInput) -> MakeOutput {
        let output: ElementOutput?
        let edges: [MakeOutput?]

        // If we have a view, evaluate it normally
        // If not, consider the view unchanged and
        // use our storage to know if `make` needs to be called on our content
        if let view = view {
            output = ElementOutput(storage: view.storageValue, attributes: view.collectAttributes())

            switch view {
                case .none:
                    edges = [nil]
                case let .some(view):
                    let wrappedInput = MakeInput(storage: input.storage?.edges[0])
                    edges = [Wrapped.make(view: view, input: wrappedInput)]
            }
        } else if let storage = input.storage, let storageValue = storage.value as? Storage {
            output = nil

            switch storageValue {
                case .none:
                    edges = [nil]
                case .some:
                    let wrappedInput = MakeInput(storage: storage.edges[0])
                    edges = [Wrapped.make(view: nil, input: wrappedInput)]
            }
        } else {
            fatalError("Cannot make an `Optional` view without a view or a storage node")
        }

        return Self.output(node: output, staticEdges: edges, accessor: view?.accessor)
    }

    /// Optional views have one edge, the wrapped view (or `nil`).
    public static func staticEdgesCount() -> Int {
        return 1
    }
}

public extension ViewBuilder {
    static func buildOptional<Content>(_ content: Content?) -> Content? where Content: View {
        return content
    }
}
