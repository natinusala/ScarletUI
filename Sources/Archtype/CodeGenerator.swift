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

// TODO: find a way to run the plugin again when the stencil changes
// TODO: filter files by import
// TODO: support all types, in the Scarlet stencil put an #error if it's anything else than a struct
// TODO: in the stencil, emit a warning if @State properties are not private

import Foundation
import Backtrace

/// Entry point for Archtype code generator. Represents a code generator
/// with a list of rules to apply on each target file.
///
/// Use with `@main` to make an executable code generator.
///
/// Execution arguments (for the plugin) are: `input_file output_file`.
public protocol CodeGenerator {
    /// Code generation tool name.
    static var name: String { get }

    /// List of all the rules.
    static var rules: [Rule] { get }

    /// Bundle of the executable containing resources.
    /// Use `Bundle.module` synthesized by Swift.
    /// If 'Bundle.module' is not found then ressources are not propertly setup in 'Package.swift'.
    static var bundle: Bundle { get }
}

public extension CodeGenerator {
    static func main() {
        do {
            Backtrace.install()

            let (input, output) = try parseArguments()

            trace("Input file: \(input.path)")
            trace("Output file: \(output.path)")

            // Parse and walk input file
            let sourceFileSyntax = try parse(input: input)
            let result = walk(sourceFile: sourceFileSyntax, matching: self.rules)

            trace("Parsing done")
            for type in result.matchingTypes {
                trace("     Found matching type '\(type.type.identifier)'")
                trace("         Applies to \(type.matchingRules.count) rules: \(type.matchingRules.map { $0.name })")
            }

            trace("Template context: \(result.context)")

            // Get a flat list of matching rules
            let rules = Set(result.matchingTypes.map { $0.matchingRules }.reduce([], +))
            trace("Running \(rules.count) rules: \(rules.map { $0.name })")

            // Render output file
            try render(rules: Array(rules), in: output, using: result.context, for: self.name, from: self.bundle)
        } catch let error as ArchtypeError {
            print("Error while running \(self.name): \(error.rawValue)")
            exit(-1)
        } catch {
            print("Error while running \(self.name): \(error)")
            exit(-1)
        }
    }
}

private func parseArguments() throws -> (input: URL, output: URL) {
    guard CommandLine.arguments.count == 3 else {
        throw ArchtypeError.missingArgument
    }

    let input = CommandLine.arguments[1]
    let output = CommandLine.arguments[2]

    guard FileManager.default.fileExists(atPath: input) else {
        throw ArchtypeError.inputNotFound
    }

    return (
        input: URL(fileURLWithPath: input),
        output: URL(fileURLWithPath: output)
    )
}
