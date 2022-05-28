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

public struct ForEach<Data, ID, Content>: View where Data: RandomAccessCollection, ID: Hashable, Content: View {
    public typealias Body = Never
    public typealias Implementation = Never

    /// The input collection.
    let data: Data

    /// The content to render for each element.
    let content: (Data.Element) -> Content

    /// The identifier to use for each element.
    let id: (Data.Element) -> ID
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
