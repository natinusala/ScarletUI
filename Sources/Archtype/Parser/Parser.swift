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

import Foundation
import Stencil
import SwiftSyntax
import SwiftParser

/// Parses the given Swift file and outputs its syntaxic node.
func parse(input: URL) throws -> SourceFileSyntax {
    trace("Parsing input file")

    let content = try String(contentsOf: input)
    return Parser.parse(source: content)
}

/// Walk the given source file and returns the corresponding Stencil context.
/// If the returned value is `nil` it means that no type in the input file matches
/// the requested rule, and as such the template rendering should not be performed.
func walk(sourceFile: SourceFileSyntax, matching rules: [Rule]) -> ParseResult {
    let visitor = InputFileVisitor(matching: rules)

    visitor.walk(sourceFile)

    let matchingTypes = visitor.matchingTypes

    return ParseResult(
        matchingTypes: matchingTypes,
        context: matchingTypes.context
    )
}

struct ParseResult {
    let matchingTypes: [MatchingType]
    let context: [String: Any]
}

/// A parsed type and all of its matching rules.
struct MatchingType {
    let type: ParsedType
    let matchingRules: [Rule]
}
