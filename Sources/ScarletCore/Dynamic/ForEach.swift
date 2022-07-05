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
public struct ForEach<Data, ID, Content>: View, DynamicViewContent where Data: RandomAccessCollection, Data.Index == Int, ID: Hashable, Content: View {
    struct Storage {
        /// The previous data as a list of identifiers.
        /// Used to detect insertions, removals and movements.
        let identifiers: [ID]
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
            return Self.output(node: nil, operations: [], accessor: nil, viewContent: nil)
        }

        // Iterate over all elements in the input collection, see their previous position and
        // make a list of operations out of that
        let previousIdentifiers = (input.storage?.value as? Storage)?.identifiers ?? []
        let newIdentifiers = view.data.map { view.id($0) }
        let operations = newIdentifiers.difference(from: previousIdentifiers).asDynamicOperations()

        // Finalize
        let output = ElementOutput(storage: Storage(identifiers: newIdentifiers), attributes: view.collectAttributes())
        return self.output(node: output, operations: operations, accessor: view.accessor, viewContent: view)
    }

    public static var staticEdgesCount: Int {
        fatalError("`ForEach` edges are dynamic")
    }

    public func count() -> Int {
        return data.count
    }

    public func make(at position: Int, identifiedBy id: AnyHashable, input: MakeInput) -> MakeOutput {
        let input = MakeInput(storage: input.storage?.edges.dynamicAt(id: id))
        return Content.make(view: self.content(self.data[position]), input: input)
    }

    public var dynamicViewContent: DynamicViewContent? {
        return self
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

private extension CollectionDifference where ChangeElement: Hashable {
    func asDynamicOperations() -> [DynamicOperation] {
        var operations: [DynamicOperation] = []

        for change in self {
            switch change {
            case .insert(let offset, let element, _):
                operations.append(.insert(id: element, at: offset))
            case .remove(let offset, let element, _):
                operations.append(.remove(id: element, at: offset))
            }
        }

        return operations
    }
}
