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

// A property wrapper type that can read and write a value owned by a source of truth.
@propertyWrapper
public struct Binding<Value> {
    let value: Value
    let location: StorageLocation

    public var wrappedValue: Value {
        get {
            return value
        }
        nonmutating set {
            location.set(value: newValue)
        }
    }
}
