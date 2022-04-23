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
        if glfwInit() != GLFW_TRUE {
            throw GLFWError.initFailed
        }
    }

    func poll() {
        glfwPollEvents()
    }

    func createWindow(title: String, mode: WindowMode, backend: GraphicsBackend, srgb: Bool) throws -> NativeWindow {
        return try GLFWWindow(title: title, mode: mode, backend: backend, srgb: srgb)
    }

    var name: String {
        return "GLFW"
    }
}

class GLFWWindow: NativeWindow {
    let handle: OpaquePointer?

    let size: WindowSize

    init(title: String, mode: WindowMode, backend: GraphicsBackend, srgb: Bool) throws {
        // Setup hints
        glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3)
        glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 3)
        glfwWindowHint(GLFW_OPENGL_FORWARD_COMPAT, GLFW_TRUE)
        glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE)

        glfwWindowHint(GLFW_STENCIL_BITS, 0)
        glfwWindowHint(GLFW_ALPHA_BITS, 0)
        glfwWindowHint(GLFW_DEPTH_BITS, 0)

        if srgb {
            glfwWindowHint(GLFW_SRGB_CAPABLE, GLFW_TRUE)
        }

        // Reset mode specific values
        glfwWindowHint(GLFW_RED_BITS, GLFW_DONT_CARE)
        glfwWindowHint(GLFW_GREEN_BITS, GLFW_DONT_CARE)
        glfwWindowHint(GLFW_BLUE_BITS, GLFW_DONT_CARE)
        glfwWindowHint(GLFW_REFRESH_RATE, GLFW_DONT_CARE)

        // Get monitor and mode
        let monitor = glfwGetPrimaryMonitor()

        if monitor == nil {
            throw GLFWError.noPrimaryMonitor
        }

        guard let videoMode = glfwGetVideoMode(monitor) else {
            throw GLFWError.noVideoMode
        }

        // Create the new window
        switch mode {
            // Windowed mode
            case let .windowed(width, height):
                self.handle = glfwCreateWindow(
                    Int32(width),
                    Int32(height),
                    title,
                    nil,
                    nil
                )
            // Borderless mode
            case .borderless:
                glfwWindowHint(GLFW_RED_BITS, videoMode.pointee.redBits)
                glfwWindowHint(GLFW_GREEN_BITS, videoMode.pointee.greenBits)
                glfwWindowHint(GLFW_BLUE_BITS, videoMode.pointee.blueBits)
                glfwWindowHint(GLFW_REFRESH_RATE, videoMode.pointee.refreshRate)

                self.handle = glfwCreateWindow(
                    videoMode.pointee.width,
                    videoMode.pointee.height,
                    title,
                    monitor,
                    nil
                )
            // Fullscreen mode
            case .fullscreen:
                self.handle = glfwCreateWindow(
                    videoMode.pointee.width,
                    videoMode.pointee.height,
                    title,
                    monitor,
                    nil
                )
        }

        if self.handle == nil {
            throw GLFWError.cannotCreateWindow
        }

        // Initialize graphics API
        glfwMakeContextCurrent(handle)

        switch backend {
            case .gl:
                gladLoadGLLoaderFromGLFW()

                #if DEBUG_GRAPHICS_BACKEND
                    glEnable(GLenum(GL_DEBUG_OUTPUT))
                    glDebugMessageCallback(
                        { _, type, id, severity, _, message, _ in
                            onGlDebugMessage(severity: severity, type: type,  id: id, message: message)
                        },
                        nil
                    )
                #endif
        }

        // Enable sRGB if requested
        if srgb {
            switch backend {
                case .gl:
                    glEnable(UInt32(GL_FRAMEBUFFER_SRGB))
            }
        }

        var actualWindowWidth: Int32 = 0
        var actualWindowHeight: Int32 = 0
        glfwGetWindowSize(handle, &actualWindowWidth, &actualWindowHeight)

        self.size = WindowSize(width: Float(actualWindowWidth), height: Float(actualWindowHeight))

        // TODO: Initialize context

        // Finalize init
        glfwSwapInterval(1)

        // TODO: Set the `GLFWWindow` pointer as GLFW window userdata
        // TODO: Setup resize callback
    }

    var shouldClose: Bool {
        return glfwWindowShouldClose(self.handle) == 1
    }

    func swapBuffers() {
        // TODO: gr_direct_context_flush(self.skContext)
        glfwSwapBuffers(self.handle)
    }
}

/// GLFW errors.
enum GLFWError: Error {
    case initFailed
    case noPrimaryMonitor
    case noVideoMode
    case cannotCreateWindow
}

#if DEBUG_GRAPHICS_BACKEND
private func onGlDebugMessage(severity: GLenum, type: GLenum, id: GLuint, message: UnsafePointer<CChar>?) {
    Logger.debug("OpenGL \(severity) \(id): \(message.str ?? "unspecified")")
}
#endif
