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

/// A node for "stateful" elements. Stateful elements are elements that:
/// - may have dynamic properties
/// - need to be compared before updating (equality check)
///
/// Stateful element nodes store their element for that purpose.
/// Only stateful elements are installed.
///
/// All user elements are stateful.
public protocol StatefulElementNode: ElementNode {
    /// Value for the element.
    var value: Value { get set }

    /// Last context used to update the element.
    /// Used to update it again if a dynamic property changes.
    var context: Context { get set }

    /// Last implementation position used to update the element.
    /// Used to update it again if a dynamic property changes.
    var implementationPosition: Int { get set }
}

public extension StatefulElementNode {
    /// Default implementation for stored element nodes: compare the stored value
    /// with the new one.
    func shouldUpdate(with element: Value, using context: ElementNodeContext) -> Bool {
        return !elementEquals(lhs: self.value, rhs: element)
    }

    func storeValue(_ value: Value) {
        self.value = value
    }

    func storeContext(_ context: Context) {
        self.context = context
    }

    func storeImplementationPosition(_ position: Int) {
        self.implementationPosition = position
    }

    var valueDebugDescription: String {
        return self.value.debugDescription
    }

    func compareAndUpdate(with element: Value?, implementationPosition: Int, using context: Context) -> UpdateResult {
        // If no element is given, assume the view is unchanged so perform an update giving `nil` as element
        // TODO: Compare environment versions and if it changed, install the new environment values inside
        //       the stored value and run the update with that
        guard let element else {
            return self.update(with: nil, implementationPosition: implementationPosition, using: context)
        }

        // If any dynamic variable changed, always install and update the view since
        // we know it's outdated
        if context.dynamicVariableChanged {
            var installed = element
            self.install(element: &installed, using: context)

            return self.update(with: installed, implementationPosition: implementationPosition, using: context)
        }

        // Then compare fields ignoring dynamic variables
        if self.shouldUpdate(with: element, using: context) {
            var installed = element
            self.install(element: &installed, using: context)

            return self.update(with: installed, implementationPosition: implementationPosition, using: context)
        }

        // TODO: check if we are inside a ViewModifier - if not, there is no point to continue here.
        //       Instead, continue by checking if any subsequent node has different context
        //       and restart the update there

        // Otherwise give `nil` if the element is equal to the previous one
        // since some distant edges may change depending on context
        return self.update(with: nil, implementationPosition: implementationPosition, using: context)
    }

    func install(element: inout Value, using context: ElementNodeContext) {
        func installStateProperty(property: any StateProperty, metadata: PropertyInfo) throws -> (any DynamicProperty)? {
            // If the location is set, copy the whole state property from storage
            // Otherwise, set its location up
            if property.location != nil {
                return try metadata.get(from: self.value)
            } else {
                let location = property.makeLocation(node: self)
                return property.withLocation(location)
            }
        }

        do {
            try element.visitDynamicProperties { name, offset, property, metadata in
                switch property {
                    case let stateProperty as any StateProperty:
                        return try installStateProperty(property: stateProperty, metadata: metadata)
                    default:
                        fatalError("Cannot install dynamic properties of \(Self.self): unsupported type \(type(of: property))")
                }
            }
        } catch {
            fatalError("Cannot install dynamic properties of \(Self.self): \(error)")
        }
    }

    /// Called when a state property has a value change.
    func notifyStateChange() {
        // Take the stored value and make it again as it is
        // Set context state change
        let context = self.context.settingStateChange()
        _ = self.update(with: self.value, implementationPosition: self.implementationPosition, using: context)
    }
}
