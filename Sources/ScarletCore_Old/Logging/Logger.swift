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

import Rainbow

public actor Logger {
    // TODO: implement "labels" so that apps can enable / disable Scarlet logs
    // TODO: replace debug bools by debug facets with a name and add a prefix
    // TODO: use #file, #line and #function to improve debug messages

    /// Logs an informative message.
    public static func info(_ message: @autoclosure () -> String) {
        print("\("[INFO]".blue) \(message())")
    }

    /// Logs a warning message.
    public static func warning(_ message: @autoclosure () -> String) {
        print("\("[WARNING]".yellow) \(message())")
    }

    /// Logs an error message.
    public static func error(_ message: @autoclosure () -> String) {
        print("\("[ERROR]".red) \(message())")
    }

    /// Logs a debug message. The first parameter is used to toggle debug logs for
    /// components of the library at compile time.
    /// Change the debug flags for components in `Debug.swift`.
    public static func debug(_ dbg: Bool, _ message: @autoclosure () -> String) {
        if dbg {
            print("\("[DEBUG]".green) \(message())")
        }
    }
}
