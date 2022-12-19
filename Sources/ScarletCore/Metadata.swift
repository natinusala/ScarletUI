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

typealias TypeInfo = Runtime.TypeInfo
typealias PropertyInfo = Runtime.PropertyInfo

/// Returns cached type info.
func cachedTypeInfo(of type: Any.Type) throws -> TypeInfo {
    metadataLogger.debug("Requesting type info of \(type)")

    let key = ObjectIdentifier(type)

    if let info = cache[key] {
        metadataLogger.debug("  Found in cache")
        return info
    }

    metadataLogger.debug("  Missing from cache, resolving from metadata")

    let info = try typeInfo(of: type)
    cache[key] = info
    return info
}

private var cache: [ObjectIdentifier: TypeInfo] = [:]
