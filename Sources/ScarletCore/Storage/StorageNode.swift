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

/// An element storage graph node. Stores the app / scene / view itself as well as
/// state variables.
public class StorageNode {
    /// Type of the element this storage node belongs to.
    public var elementType: Any.Type

    /// Node value.
    public var value: Any?

    /// Node edges.
    public var edges: [StorageNode?]

    /// Creates a new empty storage node for the given view.
    init<V: View>(for view: V) {
        self.elementType = V.self
        self.value = nil
        self.edges = [StorageNode?](repeating: nil, count: V.staticEdgesCount())
    }

    /// Creates a new empty storage node for the given app.
    init<A: App>(for app: A) {
        self.elementType = A.self
        self.value = nil
        self.edges = [StorageNode?](repeating: nil, count: A.staticEdgesCount())
    }

    init(elementType: Any.Type, value: Any?, edges: [StorageNode?]) {
        self.elementType = elementType
        self.value = value
        self.edges = edges
    }
}
