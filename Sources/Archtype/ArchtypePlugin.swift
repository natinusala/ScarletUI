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

/*
    XXX: Since SPM does not allow plugins to depend on other libraries (besides Foundation), you will have to 
    copy this file to your plugin's source directory for now.
*/

#if canImport(PackagePlugin)
import PackagePlugin
#else
/// Shim BuildToolPlugin protocol.
protocol BuildToolPlugin {}
#endif

/// Defines a list of rules dictating what stencils to run on what types of the project
/// the plugin is applied on (the target project).
///
/// Create a struct conforming to this protocol annotated with `@main` in your plugin's Swift file.
protocol ArchtypePlugin: BuildToolPlugin {
    /// Name of the plugin.
    static var name: String { get }

    /// List of all the rules.
    static var rules: [Rule] { get }
}

extension ArchtypePlugin {
    static var name: String {
        return String(describing: Self.self)
    }
}

/// Represents a Swift type that Archtype can generate extensions for.
enum SwiftType {
    case `struct`
}

/// Describes a type of the target project.
struct TypeFilter {
    let `type`: SwiftType
    let conformingTo: [String]?
}

/// A rule is a combination of a type filter and a stencil file to run for all matching
/// types of the target project.
struct Rule {
    let name: String
    let typeFilter: TypeFilter
    let stencil: String
    let displayName: (String) -> String
}

extension Rule {
    static func rule(named name: String, type: SwiftType, conformingTo protocols: [String]?, stencil: String, displayName: @escaping (String) -> String) -> Rule {
        return Rule(
            name: name,
            typeFilter: TypeFilter(type: type, conformingTo: protocols), 
            stencil: stencil,
            displayName: displayName
        )
    }
}

#if canImport(PackagePlugin)
extension ArchtypePlugin {
    func createBuildCommands(context: PluginContext, target: Target) async throws -> [Command] {
        // XXX: `fatalError` instead of throwing an error since regular errors do not interrupt the building
        // process for some reason?
        guard let tool = try? context.tool(named: "Archtype") else { fatalError("Could not find Archtype tool") }

        // Filter out non-Swift targets
        guard let target = target as? SwiftSourceModuleTarget else {
            return []
        }

        // Return a build command for every rule for every Swift file in the target
        return Self.rules.map { rule in
            target.sourceFiles.map { sourceFile in
                let output = context.pluginWorkDirectory.appending("\(sourceFile.path.stem)_\(rule.name).swift")

                return Command.buildCommand(
                    displayName: rule.displayName(sourceFile.path.lastComponent),
                    executable: tool.path,
                    arguments: [

                    ],
                    inputFiles: [sourceFile.path],
                    outputFiles: [output]
                )
            }
        }.reduce([], +)
    }
}
#endif
