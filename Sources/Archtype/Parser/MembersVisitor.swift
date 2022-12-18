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

import SwiftSyntax

/// Visitor used to walk members of a matching type.
class MembersVisitor: SyntaxVisitor {
    /// Properties of the type.
    /// Populated when calling ``walk``.
    var properties: [Property] = []

    init() {
        super.init(viewMode: .fixedUp)
    }

    override func visit(_ node: VariableDeclSyntax) -> SyntaxVisitorContinueKind {
        // Get attributes
        let attributes = node.attributes?.compactMap { (attribute) -> Attribute? in
            switch attribute {
                case .attribute(let attribute):
                    return .attribute(name: attribute.attributeName.text)
                case .customAttribute(let customAttribute):
                    guard let type = customAttribute.attributeName.as(SimpleTypeIdentifierSyntax.self) else {
                        return nil
                    }
    
                    return .customAttribute(name: type.name.text)
                default:
                    return nil
            }
        } ?? []

        // Get access modifier
        var accessModifier: AccessModifier?
        if let modifiers = node.modifiers {
            for modifier in modifiers {
                accessModifier = AccessModifier(rawValue: modifier.name.text)
            }
        }

        // Get all variables in declaration
        for binding in node.bindings {
            guard let identifierPatternSyntax = binding.pattern.as(IdentifierPatternSyntax.self) else {
                trace("Skipping '\(binding)': not an identifier")
                continue
            }

            trace("Found property '\(identifierPatternSyntax.identifier.text)'")
            trace("     Attributes: \(attributes)")
            trace("     Access modifier: \(String(describing: accessModifier))")

            self.properties.append(
                Property(
                    name: identifierPatternSyntax.identifier.text,
                    attributes: attributes,
                    accessModifier: accessModifier
                )
            )
        }

        return .skipChildren
    }
}
