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

import ArgumentParser
import Foundation
import Logging
import Cutelog

// TODO: how to allow adding user arguments too while merging `--help` messages?

public struct Arguments: ParsableCommand {
    @Flag(help: "Log level. If using debug or trace, originating file name and line will be displayed with every message.")
    var logLevel = Logger.Level.info

    @Flag(help: "Disable colors from logs if your terminal doesn't support them.")
    var disableLogColors = false

    @Option(help: "Send logs to cutelog on this network address (port: \(Cutelog.defaultPort)).")
    var cutelog: String?

    @Flag(help: "Enable benchmarking logs?")
    var benchmark = false

    // TODO: Move this option to ScarletUI somehow
    @Option(help: "Run the app in preview mode, previewing a view conforming to `Preview`.")
    public var preview: String?

    // TODO: Move this option to ScarletUI somehow
    @Flag(help: "List all available previews in stdout and exit.")
    public var listPreviews = false

    public init() {}

    init(testing: Bool = false) {
        if testing {
            self.logLevel = .info
            self.disableLogColors = false
            self.cutelog = nil
            self.benchmark = false
            self.preview = nil
            self.listPreviews = false
        }
    }

    public static var _commandName: String {
        let executablePath = CommandLine.arguments[0]
        let url = URL(fileURLWithPath: executablePath)

        return url.pathComponents.last ?? executablePath
    }
}

extension Logger.Level: EnumerableFlag {}
