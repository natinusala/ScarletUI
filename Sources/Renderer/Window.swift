/*
   Copyright 2023 natinusala

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

/// A renderer instance inside a window.
/// Serves as root for the render tree.
///
/// As the renderer is backed by a single Dart VM, there can be only one
/// running window at a time.
/// 
/// Due to how the Flutter Engine works, the window must be created
/// before initializing the Dart VM. That means creating any render object
/// before the window is ready will result in an abort.
public protocol Window: RenderObject {
    /// Create a new window with given parameters.
    ///
    /// The window only accepts children nodes once ``run()`` has been called
    /// and once the renderer is ready (``WindowDelegate/onWindowReady()``). Using the window
    /// or creating any render object before that will abort.
    init(title: String, mode: WindowMode, delegate: WindowDelegate) throws

    /// Open the window, initialize and start the renderer.
    /// This method never returns since the thread is parked by the Flutter scheduler.
    ///
    /// Once the renderer is ready to be used, ``WindowDelegate/onWindowReady()`` is called
    /// on the window delegate. Do not try to create render objects or
    /// add children nodes before that.
    func start() throws -> Never
}

public protocol WindowDelegate {
    /// Called when the renderer is initialized and the window is ready
    /// to accept children nodes.
    func onWindowReady()
}

/// The mode of a window.
public enum WindowMode: Equatable {
    /// Windowed window with given initial width and height.
    case windowed(width: Float, height: Float)

    /// Fullscreen borderless window.
    case borderless

    /// Fullscreen application.
    case fullscreen

    public static func `default`() -> WindowMode {
        return .windowed(width: defaultWindowWidth, height: defaultWindowHeight)
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

public struct WindowSize {
    let width: Int
    let height: Int
}

/// Create and open a new window.
/// Entry point for the renderer.
public func createWindow(title: String, mode: WindowMode = .default(), delegate: WindowDelegate) throws -> any Window {
    return try GLFWWindow(title: title, mode: mode, delegate: delegate)
}
