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

/// Represents a Swift type that Archtype can generate code for.
public enum SwiftType {
    case `struct`
}

/// Describes a type of the target project.
public struct TypeFilter {
    let `type`: SwiftType
    let conformingTo: [String]
}

/// A rule is a combination of a type filter and a stencil file to run for all matching
/// types of the target project.
public struct Rule: Hashable {
    let name: String
    let typeFilter: TypeFilter
    let template: String

    func matches(node: StructDeclSyntax) -> Bool {
        trace("Checking if the type matches")

        // Check decl type
        if typeFilter.type != .struct {
            trace("Type doesn't match")
            return false
        }

        // Check inheritance clauses
        if let inheritanceClause = node.inheritanceClause {
            // Inheritance clause: match against conformance list
            trace("Checking inheritance clauses")
            return self.matches(inheritanceClause: inheritanceClause)
        } else {
            // No inheritance clause: it matches if the list is also empty
            let result = typeFilter.conformingTo.isEmpty
            trace("Type has no inheritance clauses: returning \(result)")
            return result
        }
    }

    private func matches(inheritanceClause: TypeInheritanceClauseSyntax) -> Bool {
        return inheritanceClause.inheritedTypeCollection.contains(where: { (inheritedTypeSyntax) -> Bool in
            let typeSyntax = inheritedTypeSyntax.typeName

            guard let simpleTypeIdentifierSyntax = typeSyntax.as(SimpleTypeIdentifierSyntax.self) else {
                trace("Skipping inheritance clause: cannot be cast to 'SimpleTypeIdentifierSyntax'")
                return false
            }

            let typeName = simpleTypeIdentifierSyntax.name.text

            trace("Evaluating inheritance clause '\(typeName)'")

            return self.typeFilter.conformingTo.contains(typeName)
        })
    }

    public static func == (lhs: Rule, rhs: Rule) -> Bool {
        return lhs.name == rhs.name
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.name)
    }
}

public extension Rule {
    static func rule(named name: String, type: SwiftType, conformingTo protocols: [String], template: String) -> Rule {
        return Rule(
            name: name,
            typeFilter: TypeFilter(type: type, conformingTo: protocols),
            template: template
        )
    }
}

enum ArchtypeError: String, Error {
    case missingArgument = "One or more arguments are missing."
    case inputNotFound = "Input file not found."
    case outputEncodingError = "Output file encoding error."
    case wrongTemplateFileName = "Wrong template file name - it must follow the '<##Name##>.stencil' pattern."
    case templateNotFound = "Template file not found in bundle, is it declared as a processed resource in 'Package.swift'?"
    case cannotOpenOutputFile = "Cannot open output file."
}
