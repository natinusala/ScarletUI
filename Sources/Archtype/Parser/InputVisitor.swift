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

/// Top level visitor used to walk input files.
/// ``walk()`` should be called once and only once per visitor lifetime.
class InputFileVisitor: SyntaxVisitor {
    let rules: [Rule]

    /// List of all found matching types.
    /// Populated when calling ``walk``.
    var matchingTypes: [MatchingType] = []

    init(matching rules: [Rule]) {
        self.rules = rules

        super.init(viewMode: .fixedUp)
    }

    override func visit(_ node: StructDeclSyntax) -> SyntaxVisitorContinueKind {
        trace("Visiting struct '\(node.identifier.text)'")

        // Filter matching rules
        let matchingRules = self.rules.filter { rule in
            rule.matches(node: node)
        }

        trace("Found \(matchingRules.count) matching rule(s): \(matchingRules.map { $0.name })")

        let membersVisitor = MembersVisitor()
        membersVisitor.walk(node)

        self.matchingTypes.append(
            MatchingType(
                type: ParsedType(
                    identifier: node.identifier.text,
                    type: .struct,
                    properties: membersVisitor.properties
                ),
                matchingRules: matchingRules
            )
        )

        return .skipChildren
    }
}
