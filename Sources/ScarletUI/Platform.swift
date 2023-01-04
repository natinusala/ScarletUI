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

import Needler

/// Result of a platform "poll" call.
struct PollResult {
    /// The state of the gamepad at the time of the poll.
    let gamepadState: _GamepadState
}

/// Allows interfacing with the platform the app is currently running on.
public protocol _Platform {
    init() throws

    /// Human readable platform name.
    var name: String { get }

    /// Poll events.
    func pollEvents()

    /// Creates, opens and makes current a new window.
    func createWindow(title: String, mode: WindowMode, backend: GraphicsBackend, srgb: Bool) throws -> _NativeWindow
}

private var currentPlatform: _Platform?

protocol PlatformResolver: DebugInjectable {
    /// Creates and returns the current platform handle.
    func createPlatform() throws -> _Platform?
}

extension PlatformResolver {
    static var defaultValue: any PlatformResolver {
        return DefaultPlatformResolver()
    }
}

struct DefaultPlatformResolver: PlatformResolver {
    func createPlatform() throws -> _Platform? {
        // TODO: only return GLFW if actually available
        return try GLFWPlatform()
    }
}

/// A native, platform-dependent window.
public protocol _NativeWindow {
    typealias WindowSize = (width: Float, height: Float)

    /// Should return true if the platform requested the window to close.
    var shouldClose: Bool { get }

    /// The window position. Only available when running in windowed.
    var position: (x: Int, y: Int)? { get set }

    /// Window dimensions.
    var size: WindowSize { get }

    /// Graphics context for this window.
    var context: _GraphicsContext { get }

    /// Swap graphic buffers ("flush" the canvas).
    func swapBuffers()

    /// Polls the gamepad to get input at the current frame.
    /// Tied to the window and not the platform for keyboard inputs.
    ///
    /// Virtual input should all be set to their default value as they are
    /// automatically set afterwards.
    //
    /// Timing can be critical for some app's input processing.
    /// As such, this function should return the gamepad state at the exact time of calling,
    /// and result should not be cached from an early poll.
    ///
    /// Every frame, the polling cycle is the following:
    /// - poll events
    /// - poll gamepad state into a `GamepadState` struct
    ///     - keyboard to gamepad buttons translation is done by the platform input code if needed
    /// - translate that state into a `VirtualGamepadState` struct by adding virtual buttons and applying axis to DPAD translation
    /// - check for buttons that were pressed or released since the last poll
    /// - this gives a list of buttons that are "pressed" at the current frame but were not at the previous one
    /// - make events out of that list
    func pollGamepad() -> _GamepadState
}

/// The mode of a window.
public enum WindowMode: Equatable {
    /// Windowed window with given initial width and height.
    case windowed(width: Float, height: Float)

    /// Fullscreen borderless window.
    case borderless

    /// Fullscreen application.
    case fullscreen

    public static func getDefault() -> WindowMode {
        return .windowed(width: 1280, height: 720)
    }

    /// Full, human-redable name.
    var name: String {
        switch self {
            case .windowed:
                return "windowed"
            case .borderless:
                return "fullscreen borderless"
            case .fullscreen:
                return "fullscreen"
        }
    }
}

