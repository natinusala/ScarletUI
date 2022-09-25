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

/// An injected dependency.
protocol Dependency {
    /// The type of the dependency.
    associatedtype Value

    /// The default value to use for that dependency when running the
    /// program in a production environment.
    static var defaultValue: Value { get }
}

/// Global, unique container for injected dependencies.
/// Use it like environment values.
class Dependencies {
    private static var values: [ObjectIdentifier: Any] = [:]

    static subscript<K>(key: K.Type) -> K.Value where K: Dependency {
        get {
            if let value = Dependencies.values[ObjectIdentifier(key)] as? K.Value {
                return value
            } else {
                let value = K.defaultValue
                Dependencies.values[ObjectIdentifier(key)] = value
                return value
            }
        }
        set {
            Dependencies.values[ObjectIdentifier(key)] = newValue
        }
    }
}
