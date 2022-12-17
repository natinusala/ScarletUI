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

import PackagePlugin

@main
struct ScarletUICodegen: BuildToolPlugin {
    func createBuildCommands(context: PluginContext, target: Target) async throws -> [Command] {
        // XXX: `fatalError` instead of throwing an error since regular errors do not interrupt the building process for some reason?
        guard let tool = try? context.tool(named: "ScarletUIMetadata") else { fatalError("Could not find ScarletUIMetadata tool") }

        // Filter out non-Swift targets
        guard let target = target as? SwiftSourceModuleTarget else {
            return []
        }

        // Return a build command for every rule for every Swift file in the target
        return target.sourceFiles.map { sourceFile in
            let output = context.pluginWorkDirectory.appending("\(sourceFile.path.stem)_ScarletUIMetadata.swift")

            return Command.buildCommand(
                displayName: "Generating metadata for \(sourceFile.path.lastComponent)...",
                executable: tool.path,
                arguments: [
                    sourceFile.path.string,
                    output.string,
                ],
                inputFiles: [sourceFile.path],
                outputFiles: [output]
            )
        }
    }
}
