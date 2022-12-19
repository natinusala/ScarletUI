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

import Runtime

/// Returns cached type info.
func cachedTypeInfo<T>(of type: T.Type) throws -> TypeInfo {
    let key = ObjectIdentifier(type)

    if let info = cache[key] {
        return info
    }

    let info = try typeInfo(of: type)
    cache[key] = info
    return info
}

private var cache: [ObjectIdentifier: TypeInfo] = [:]
