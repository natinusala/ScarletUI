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

/// Result of a platform "poll" call.
struct PollResult {
    /// The state of the gamepad at the time of the poll.
    let gamepadState: GamepadState
}

/// Allows interfacing with the platform the app is currently running on.
public protocol Platform {
    init() throws

    /// Human readable platform name.
    var name: String { get }

    /// Poll events.
    func pollEvents()

    /// Creates, opens and makes current a new window.
    func createWindow(title: String, mode: WindowMode, backend: GraphicsBackend, srgb: Bool) throws -> NativeWindow
}

fileprivate var currentPlatform: Platform?

/// Creates and returns the current platform handle.
func createPlatform() throws -> Platform? {
    // TODO: only return GLFW if actually available
    return try GLFWPlatform()
}

/// A native, platform-dependent window.
public protocol NativeWindow {
    typealias WindowSize = (width: Float, height: Float)

    /// Should return true if the platform requested the window to close.
    var shouldClose: Bool { get }

    /// Window dimensions.
    var size: WindowSize { get }

    /// Graphics context for this window.
    var context: GraphicsContext { get }

    /// Swap graphic buffers ("flush" the canvas).
    func swapBuffers()

    /// Polls the gamepad to get input at the current frame.
    /// See ``Platform/pollGamepad()``.
    func pollGamepad() -> _PhysicalGamepadState
}

/// The mode of a window.
public enum WindowMode: Equatable {
    /// Windowed window with given initial width and height.
    case windowed(Float, Float)

    /// Fullscreen borderless window.
    case borderless

    /// Fullscreen application.
    case fullscreen

    public static func getDefault() -> WindowMode {
        return .windowed(defaultWindowWidth, defaultWindowHeight)
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

