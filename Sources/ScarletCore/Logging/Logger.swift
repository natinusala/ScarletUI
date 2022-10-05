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

import Logging
import ConsoleKit

// TODO: add option to log to file (is rotation needed?)

/// Creates a new logger with the given label.
public func createLogger(label: String) -> Logging.Logger {
    return Logging.Logger(label: label, factory: { _ in
        let consoles = [terminalConsole]

        return Logging.MultiplexLogHandler(consoles.map { console in
            console.stylizedOutputOverride = !arguments.disableLogColors

            return ConsoleLogger(
                label: label,
                console: console,
                level: arguments.logLevel
            )
        })
    })
}

private let terminalConsole = Terminal()
