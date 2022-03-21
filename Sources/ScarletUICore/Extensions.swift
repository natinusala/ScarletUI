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

extension Collection {
    /// Returns the element at the specified index if it is within bounds, otherwise `nil`.
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

extension Sequence {
    /// Returns `true` if all elements of the sequence match the given predicate,
    /// `false` otherwise.
    func all(predicate: (Element) -> Bool) -> Bool {
        for element in self {
            if !predicate(element) {
                return false
            }
        }

        return true
    }
}
