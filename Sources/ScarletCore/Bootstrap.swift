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

/// Bootstraps ScarletCore and all of its systems.
/// Must be called by the implementation library on `main`, before creating the app.
/// If running from a test environment, specify `testing` to disable arguments parsing (that would clash with XCTest's own arguments).
public func bootstrap(testing: Bool = false) {
    let arguments: Arguments
    if testing {
        arguments = .init(testing: true)
    } else {
        arguments = Arguments.parseOrExit()
    }

    bootstrapLogger(arguments: arguments)
}

/// Tears down ScarletCore and all of its systems.
/// Useful to flush log files for example.
public func teardown() {
    teardownLogger()
}
