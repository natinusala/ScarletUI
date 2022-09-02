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

import Skia
import Glad
import GLFW

import ScarletNative

/// GLFW as a platform.
class GLFWPlatform: Platform {
    required init() throws {
        // Set error callback
        glfwSetErrorCallback {code, error in
            Logger.error("GLFW error \(code): \(error.str ?? "unknown")")
        }

        // Init GLFW
        glfwInitHint(GLFW_JOYSTICK_HAT_BUTTONS, GLFW_TRUE);

        if glfwInit() != GLFW_TRUE {
            throw GLFWError.initFailed
        }
    }

    func pollEvents() {
        glfwPollEvents()
    }

    func createWindow(title: String, mode: WindowMode, backend: GraphicsBackend, srgb: Bool) throws -> NativeWindow {
        return try GLFWWindow(title: title, mode: mode, backend: backend, srgb: srgb)
    }

    var name: String {
        return "GLFW"
    }
}

/// GLFW errors.
enum GLFWError: Error {
    case initFailed
    case noPrimaryMonitor
    case noVideoMode
    case cannotCreateWindow
}
