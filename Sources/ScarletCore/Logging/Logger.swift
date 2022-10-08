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
import Logging
import ConsoleKit
import Builders

let cutelogAddressEnv = "SCARLET_CUTELOG_ADDRESS"
let logLevelEnv: String = "SCARLET_LOG_LEVEL"

// TODO: add option to log to file (is rotation needed?)

func bootstrapLogger(arguments: Arguments) {
    // Get log level address either from CLI arguments or
    // from the environment variable for testing
    let logLevel: Logger.Level
    if let logLevelEnvironment = ProcessInfo.processInfo.environment[logLevelEnv],
       let parsedLogLevel = Logger.Level(rawValue: logLevelEnvironment)
    {
        logLevel = parsedLogLevel
    } else {
        logLevel = arguments.logLevel
    }

    // Create one Cutelog logger for the target address and reuse it in
    // multiple handlers in the factory
    #if DEBUG
    let cutelogLogger: CutelogLogger?

    // Get cutelog address either from CLI arguments or
    // from the environment variable for testing
    let cutelogAddress: String?
    if let addressArgument = arguments.cutelog {
        cutelogAddress = addressArgument
    } else if let addressEnvironment = ProcessInfo.processInfo.environment[cutelogAddressEnv] {
        cutelogAddress = addressEnvironment
    } else {
        cutelogAddress = nil
    }

    if let cutelogAddress {
        // Create the internal Cutelog logger
        let internalCutelogLogger = Logger(label: "cutelog", factory: { label in
            let terminal = Terminal()
            terminal.stylizedOutputOverride = !arguments.disableLogColors

            return ConsoleLogger(
                label: label,
                console: terminal,
                level: logLevel
            )
        })

        let logger = CutelogLogger(
            address: cutelogAddress,
            port: defaultCutelogPort,
            internalLogger: internalCutelogLogger
        )

        cutelogLogger = logger
        teardownHandlers.append({ logger.flush() })
    } else {
        cutelogLogger = nil
    }
    #endif

    // Executed for every new logger to create its handlers
    LoggingSystem.bootstrap { label in
        // Terminal
        let terminal = Terminal()
        terminal.stylizedOutputOverride = !arguments.disableLogColors

        let terminalHandler: LogHandler = ConsoleLogger(
            label: label,
            console: terminal,
            level: logLevel
        )

        // Final handlers list
        let handlers: [LogHandler] = .init {
            #if DEBUG
            if let cutelogLogger {
                cutelogLogger.makeHandler(label: label, logLevel: logLevel)
            }
            #endif

            terminalHandler
        }

        return MultiplexLogHandler(handlers)
    }
}

func teardownLogger() {
    teardownHandlers.forEach { handler in
        handler()
    }
}

private var teardownHandlers: [() -> ()] = []
