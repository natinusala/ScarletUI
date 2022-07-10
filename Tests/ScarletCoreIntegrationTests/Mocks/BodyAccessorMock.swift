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

@testable import ScarletCore

class BodyAccessorMock: BodyAccessor {
    var bodyCalls: [ObjectIdentifier: Int] = [:]

    let wrapped: BodyAccessor

    init(wrapping wrapped: BodyAccessor) {
        self.wrapped = wrapped
    }

    func makeBody<V: View>(of view: V, storage: StorageNode?) -> V.Body {
        bodyCalls[ObjectIdentifier(V.self)] = (bodyCalls[ObjectIdentifier(V.self)] ?? 0) + 1
        return wrapped.makeBody(of: view, storage: storage)
    }
}
