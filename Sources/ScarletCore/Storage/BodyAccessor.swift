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

protocol BodyAccessor {
    /// Makes the body of the given view.
    func makeBody<V: View>(of view: V, storage: StorageNode?) -> V.Body
}

struct DefaultBodyAccessor: BodyAccessor {
    func makeBody<V: View>(of view: V, storage: StorageNode?) -> V.Body {
        return view.body
    }
}

private struct BodyAccessorDependency: Dependency {
    static let defaultValue: BodyAccessor = DefaultBodyAccessor()
}

extension Dependencies {
    static var bodyAccessor: any BodyAccessor {
        get { Dependencies[BodyAccessorDependency.self] }
        set { Dependencies[BodyAccessorDependency.self] = newValue }
    }
}
