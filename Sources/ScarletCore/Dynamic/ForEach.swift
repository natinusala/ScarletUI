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

/// A structure that computes views on demand from an underlying collection of identified data.
public struct ForEach<Data, ID, Content>: View where Data: RandomAccessCollection, ID: Hashable, Content: View {
    struct Storage {
        /// Position of each view. Missing entry means the view was not present.
        /// Used to detect insertions, removals and movements.
        let positions: [ID: Int]
    }

    public typealias Body = Never
    public typealias Implementation = Never

    /// The input collection.
    let data: Data

    /// The content to render for each element.
    let content: (Data.Element) -> Content

    /// The identifier to use for each element.
    let id: (Data.Element) -> ID

    static public func make(view: Self?, input: MakeInput) -> MakeOutput {
        // If no view is specified, consider the view entirely unchanged,
        // including its body
        guard let view = view else {
            return Self.output(node: nil, operations: [], accessor: nil)
        }

        // Iterate over all elements in the input collection, see their previous position and
        // make a list of operations out of that
        let previousPositions = (input.storage?.value as? Storage)?.positions ?? [:]
        var newPositions: [ID: Int] = [:]
        var operations: [DynamicOperation] = []

        for (index, element) in view.data.enumerated() {
            let id = view.id(element)

            if let _ = previousPositions[id] {
                // We have the previous position: the view may have moved and may need to be updated
                // TODO: Dynamic views update not implemented
            } else {
                // We don't have the previous position: the view needs to be inserted
                let view = view.content(element)
                let input = MakeInput(storage: nil)
                let output = Content.make(view: view, input: input)
                operations.append(.insert(output, at: index, identifiedBy: id))
            }

            // Add the new position to the new storage
            newPositions[id] = index
        }

        // Remove every remaining view that is not present in the input collection
        for (id, _) in previousPositions {
            if !newPositions.contains(id) {
                fatalError("Dynamic views removal unimplemented")
            }
        }

        // Finalize
        let output = ElementOutput(storage: Storage(positions: newPositions), attributes: view.collectAttributes())
        return self.output(node: output, operations: operations, accessor: view.accessor)
    }

    static public func staticEdgesCount() -> Int {
        fatalError("`ForEach` edges are dynamic")
    }
}

/// `ForEach` variant when elements do not conform to `Identifiable`. Requires giving ID manually.
public extension ForEach {
    init(_ data: Data, id: KeyPath<Data.Element, ID>, @ViewBuilder content: @escaping (Data.Element) -> Content) {
        self.data = data
        self.content = content
        self.id = { $0[keyPath: id] }
    }
}

/// `ForEach` variant when elements conform to `Identifiable`. ID is inferred.
public extension ForEach where Data.Element: Identifiable, Data.Element.ID == ID {
    init(_ data: Data, @ViewBuilder content: @escaping (Data.Element) -> Content) {
        self.data = data
        self.content = content
        self.id = { $0.id }
    }
}
