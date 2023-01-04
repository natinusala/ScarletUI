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

// TODO: rework the system to somehow bind the default value to the injected protocol, removing the need for the key + extension boilerplate

/// An injected dependency.
public protocol Dependency {
    /// The type of the dependency.
    associatedtype Value

    /// The value to use for that dependency when running the
    /// program in release configuration.
    ///
    /// Can be overridden (in debug configuration only) by setting
    /// a new value in ``Dependencies``.
    static var value: Value { get }
}

/// Global, unique container for injected dependencies.
/// Use it like environment values.
public class Dependencies {
    private static var values: [ObjectIdentifier: Any] = [:]

    public static subscript<K>(key: K.Type) -> K.Value where K: Dependency {
        get {
#if DEBUG
            if let value = Dependencies.values[ObjectIdentifier(key)] as? K.Value {
                return value
            } else {
                let value = K.value
                Dependencies.values[ObjectIdentifier(key)] = value
                return value
            }
#else
            return K.value
#endif
        }
        set {
#if DEBUG
            Dependencies.values[ObjectIdentifier(key)] = newValue
#else
            // No-op
#endif
        }
    }
}
