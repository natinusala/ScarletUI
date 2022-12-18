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

extension Array where Element == MatchingType {
    /// Turns the types list in a usable Stencil context.
    var context: [String: Any] {
        return [
            "types": self.map { $0.type }
        ]
    }
}

/// Represents a parsed type of the input file.
struct ParsedType {
    let identifier: String
    let type: SwiftType

    let properties: [Property]
}

enum AccessModifier: String {
    case `public`
    case `private`
    case `internal`
    case `fileprivate`
}

enum Attribute {
    /// Built-in attribute such as `@objc`.
    case attribute(name: String)

    /// Custom attribute such as property wrappers.
    case customAttribute(name: String)
}

/// A property in a type.
struct Property {
    /// The property name. Doesn't include the underscore if it's a wrapped property.
    let name: String

    /// @ prefixed attributes (includes property wrappers).
    let attributes: [Attribute]

    /// Access modifier: public, private, internal, fileprivate...
    let accessModifier: AccessModifier?
}
