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

/// A type which implementation can be injected in debug builds.
/// Refine your own protocols with this one to make them injectable.
///
/// Creates a static ``shared`` property on the default implementation type that points to
/// the default implementation in release configuration, and to the injected one
/// in debug configuration (if there is any).
public protocol DebugInjectable {
    associatedtype Injected

    /// The value to use in release configuration as well as in debug
    /// configuration when nothing is injected in its place.
    /// Use in an extension of your refined protocol.
    ///
    /// Must be explicitely typed `any <#Protocol name#>` to infer ``Injected``, otherwise
    /// you won't be able to inject anything else than the default value.
    static var defaultValue: Injected { get }
}

private var values: [ObjectIdentifier: Any] = [:]

public extension DebugInjectable {
    /// Shared instance.
    static var shared: Injected {
        get {
            if let value = values[Self.key] as? Injected {
                return value
            } else {
                let value = Self.defaultValue
                values[Self.key] = value
                return value
            }
        }
        set {
#if DEBUG
            values[key] = newValue
#else
            // No-op in release configuration
#endif
        }
    }
}

private extension DebugInjectable {
    static var key: ObjectIdentifier {
        return ObjectIdentifier(Self.self)
    }
}
