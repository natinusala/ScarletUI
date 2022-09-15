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
    // TODO: implement tags so that apps can enable / disable Scarlet logs
    // TODO: replace debug bools by debug facets with a name and add a prefix

    /// Logs an informative message.
    public static func info(_ message: @autoclosure () -> String, function: String = #function) {
        print("\("[INFO]".blue) \(function) -> \(message())")
    }

    /// Logs a warning message.
    public static func warning(_ message: @autoclosure () -> String, function: String = #function) {
        print("\("[WARNING]".yellow) \(function) -> \(message())")
    }

    /// Logs an error message.
    public static func error(_ message: @autoclosure () -> String, function: String = #function) {
        print("\("[ERROR]".red) \(function) -> \(message())")
    }

    /// Logs a debug message. The first parameter is used to toggle debug logs for
    /// components of the library at compile time.
    /// Change the debug flags for components in `Debug.swift`.
    public static func debug(_ dbg: Bool, _ message: @autoclosure () -> String, function: String = #function) {
        if dbg {
            print("\("[DEBUG]".green) \(function) -> \(message())")
        }
    }
}
