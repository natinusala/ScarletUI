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

/// Input of the `make` method of a component model.
public protocol ComponentInput<Model> {
    associatedtype Model: ComponentModel
}

/// Output of the `make` method of a component model.
public protocol ComponentOutput<Model> {
    associatedtype Model: ComponentModel
}

/// The model (or "recipe") of a component of the graph: an app, a scene or a view.
public protocol ComponentModel: CustomDebugStringConvertible, IsPodable {
    /// Type of the state tracking node for this component.
    associatedtype Node: ComponentNode<Self>

    /// Type of input for this component. Used as a pivot to infer the node and output types,
    /// hence the default value (for user views). Other component types must explicitely
    /// typealias both input and output types to prevent ambiguous `makeNode()` resolution.
    associatedtype Input: ComponentInput<Self> = UserComponentInput<Self>
    associatedtype Output: ComponentOutput<Self>

    /// Type of target node for this component.
    associatedtype Target: TargetNode

    typealias Context = ComponentContext

    /// Makes the node for that component.
    static func makeNode(of component: Self, in parent: (any ComponentNode)?, targetPosition: Int, using context: Context) -> Node

    /// Makes the component, usually to get its edges.
    static func make(_ component: Self, input: Input) -> Output

    /// Returns all attributes of the component.
    static func collectAttributes(of component: Self, source: AnyHashable) -> AttributesStash
}

public extension ComponentModel {
    /// Creates the target for the view.
    static func makeTarget(of component: Self) -> Target? {
        if Target.self == Never.self {
            return nil
        }

        return Target(displayName: component.displayName)
    }

    /// Default way of collecting attributes: use runtime metadata on the component directly
    /// to gather `@Attribute` property wrappers.
    static func collectAttributes(of component: Self, source: AnyHashable) -> AttributesStash {
        return AttributesStash(
            from: Self.collectAttributesUsingTypeInfo(of: component),
            source: source
        )
    }

    /// Uses runtime metadata to collect all attributes of the given component.
    static func collectAttributesUsingTypeInfo(of component: Self) -> [AttributeTarget: any AttributeSetter] {
        return fatalAttempt(to: "collect attributes of \(Self.self)") {
            let typeInfo = try cachedTypeInfo(of: Self.self)

            var attributes: [AttributeTarget: any AttributeSetter] = [:]

            metadataLogger.debug("Collecting attributes of \(Self.self) using type info")
            for property in typeInfo.properties {
                let value = try property.get(from: component)
                if let attribute = value as? any AttributeSetter {
                    attributes[attribute.target] = attribute
                }
            }

            return attributes
        }
    }
}

public extension ComponentModel {
    func makeAnyNode(in parent: (any ComponentNode)?, targetPosition: Int, using context: Context) -> any ComponentNode {
        return Self.makeNode(of: self, in: parent, targetPosition: targetPosition, using: context)
    }
}

public extension ComponentModel {
    var debugDescription: String {
        return "\(Self.self)"
    }

    /// Display name of the component, aka. its type stripped of any generic parameters.
    var displayName: String {
        return Self.displayName
    }

    static var displayName: String {
        return String(describing: Self.self).before(first: "<")
    }
}

@resultBuilder
public struct ComponentBuilder {}
