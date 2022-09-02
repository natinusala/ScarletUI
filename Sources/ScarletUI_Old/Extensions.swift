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

extension UnsafePointer where Pointee == CChar {
    /// Converts an unsafe char* pointer to a Swift string.
    var str: String {
        return String(cString: self)
    }
}

extension Optional where Wrapped == UnsafePointer<CChar> {
    /// Converts an optional unsafe char* pointer to a Swift string.
    var str: String? {
        if let cStr = self {
            return String(cString: cStr)
        }

        return nil
    }
}

extension Error {
    /// Returns the full qualified name of the error ("Type.error").
    var qualifiedName: String {
        return "\(type(of: self)).\(self)"
    }
}

extension Collection {
    /// Returns the element at the specified index if it is within bounds, otherwise `nil`.
    /// From https://stackoverflow.com/questions/25329186/safe-bounds-checked-array-lookup-in-swift-through-optional-bindings
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
