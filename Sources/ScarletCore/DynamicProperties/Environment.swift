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

/// Identifies an environment value.
public protocol EnvironmentKey {
    associatedtype Value

    static var defaultValue: Value { get }
}

public typealias EnvironmentDiff = [PartialKeyPath<EnvironmentValues>: Bool]

/// Serves as storage for environment values.
public struct EnvironmentValues {
    /// Key is an `EnvironmentKey.Type` identifier.
    private var values: [ObjectIdentifier: Any] = [:]

    /// Subscript used by users to get and set a value from its key.
    subscript<Key>(key: Key.Type) -> Key.Value where Key: EnvironmentKey {
        get {
            if let value = self.values[ObjectIdentifier(key)] as? Key.Value {
                return value
            } else {
                return Key.defaultValue
            }
        }
        set {
            self.values[ObjectIdentifier(key)] = newValue
        }
    }
}

class EnvironmentLocation<Value>: Location {
    let keyPath: WritableKeyPath<EnvironmentValues, Value>

    var value: Value

    init(keyPath: WritableKeyPath<EnvironmentValues, Value>, value: Value) {
        self.keyPath = keyPath
        self.value = value
    }

    func get() -> Value {
        return self.value
    }

    func set(_ value: Value) {
        self.value = value
    }
}

protocol EnvironmentProperty: DynamicProperty {
    var partialKeyPath: PartialKeyPath<EnvironmentValues> { get }
}

@propertyWrapper
public struct Environment<Value>: EnvironmentProperty {
    let keyPath: WritableKeyPath<EnvironmentValues, Value>
    let location: EnvironmentLocation<Value>?

    public init(_ keyPath: WritableKeyPath<EnvironmentValues, Value>) {
        self.keyPath = keyPath
        self.location = nil
    }

    private init(keyPath: WritableKeyPath<EnvironmentValues, Value>, location: EnvironmentLocation<Value>?) {
        self.keyPath = keyPath
        self.location = location
    }

    public var wrappedValue: Value {
        get {
            guard let location = self.location else {
                fatalError("Tried to get value on non installed environment property")
            }

            return location.get()
        }
    }

    func changed(using diff: EnvironmentDiff) -> Bool {
        return diff[self.keyPath] ?? false
    }

    func withLocation(_ location: EnvironmentLocation<Value>?) -> Self {
        return Self(keyPath: keyPath, location: location)
    }

    var partialKeyPath: PartialKeyPath<EnvironmentValues> {
        return keyPath
    }

    func setValue(from values: EnvironmentValues) {
        self.location?.set(values[keyPath: self.keyPath])
    }

    func accept<Visitor: DynamicPropertiesVisitor>(
        visitor: Visitor,
        in property: PropertyInfo,
        target: inout Visitor.Visited,
        using context: ElementNodeContext
    ) throws {
        try visitor.visitEnvironmentProperty(
            property,
            current: self,
            target: &target,
            type: Value.self,
            values: context.environment,
            diff: context.changedEnvironment
        )
    }
}

public protocol EnvironmentCollectable {
    associatedtype Value

    static func collectEnvironment(of element: Self) -> (keyPath: WritableKeyPath<EnvironmentValues, Value>, value: Value)
}

/// Serves as cache for environment metadata.
/// Contains the list of all environment properties for all element types in the
/// app, to know if the element needs to be updated when an environment value changes.
class EnvironmentMetadataCache {
    static let shared = EnvironmentMetadataCache()

    private var cache: [ObjectIdentifier: Set<PartialKeyPath<EnvironmentValues>>] = [:]

    private init() {}

    /// Returns `true` if the given element needs to be updated.
    func shouldUpdate<E: Element>(element: E.Type, using diff: EnvironmentDiff) -> Bool {
        let modifiedValues: [PartialKeyPath<EnvironmentValues>] = Array(diff.filter { $1 }.keys)

        let diffSet: Set<PartialKeyPath<EnvironmentValues>> = Set(modifiedValues)
        let cacheValue = self.environmentProperties(of: element)

        // Update if the intersection of "changed environment" and "environment properties for this element"
        // is not empty -> at least one environment property needs to be updated
        return !diffSet.intersection(cacheValue).isEmpty
    }

    /// Looks up environment properties for given element in cache.
    /// If missing, throws a fatal error.
    private func environmentProperties<E: Element>(of element: E.Type) -> Set<PartialKeyPath<EnvironmentValues>> {
        let key = ObjectIdentifier(E.self)

        guard let cacheValue = self.cache[key] else {
            fatalError("Environment metadata cache not found for \(E.self) - was 'setCache(for:)' properly called?")
        }

        return cacheValue
    }

    /// Triggers a discovery on the given element and updates the cache.
    /// Doesn't do anything if a value was already present for the key.
    func setCache<E: Element>(for element: E) {
        let key = ObjectIdentifier(E.self)

        guard self.cache[key] == nil else {
            return
        }

        let value = self.discoverEnvironmentProperties(of: element)
        self.cache[key] = value
    }

    /// Discovers all environment properties of an element type using runtime metadata.
    private func discoverEnvironmentProperties<E: Element>(of element: E) -> Set<PartialKeyPath<EnvironmentValues>> {
        return fatalAttempt(to: "discover environment properties on \(E.self)") {
            let typeInfo = try cachedTypeInfo(of: E.self)

            let keyPaths = try typeInfo.properties.compactMap { property -> PartialKeyPath<EnvironmentValues>? in
                let value = try property.get(from: element)
                guard let value = value as? EnvironmentProperty else {
                    return nil
                }

                return value.partialKeyPath
            }

            return Set(keyPaths)
        }
    }
}
