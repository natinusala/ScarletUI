/*
   Copyright 2023 natinusala
   Copyright 2013 The Flutter Authors

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

import FlutterEngine
import Glad
import GLFW

import CRenderer

// TODO: reinstate Logger and remove fatalErrors / prints / use exceptions if possible
// TODO: damage region and the other "expect reduced performance warning" - inspire from both embedded glfw_drm and the "regular" npn-embedded GLFW

/// A renderer instance backed by a GLFW window.
class GLFWWindow: Window {
    let delegate: WindowDelegate

    /// The GLFW window displayed to the user.
    let window: OpaquePointer

    /// The invisible GLFW window, shared with the first one, used to upload resources in the background.
    let resourceWindow: OpaquePointer

    /// The currently running Flutter Engine.
    var engine: FlutterEngine?

    var size: WindowSize

    required init(title: String, mode: WindowMode, delegate: WindowDelegate) throws {
        self.delegate = delegate

        // Init GLFW
        glfwSetErrorCallback { error, description in
            if let description {
                print("GLFW ERROR \(error): \(String(cString: description))")
            } else {
                print("GLFW ERROR \(error)")
            }
        }
        glfwInitHint(GLFW_JOYSTICK_HAT_BUTTONS, GLFW_TRUE)

        if glfwInit() != GLFW_TRUE {
            throw GLFWError.initFailed
        }

        // Set hints
        glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3)
        glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 3)
        glfwWindowHint(GLFW_OPENGL_FORWARD_COMPAT, GLFW_TRUE)
        glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE)
        glfwWindowHint(GLFW_CONTEXT_CREATION_API, GLFW_EGL_CONTEXT_API)

        glfwWindowHint(GLFW_STENCIL_BITS, 0)
        glfwWindowHint(GLFW_ALPHA_BITS, 0)
        glfwWindowHint(GLFW_DEPTH_BITS, 0)

        glfwWindowHint(GLFW_SRGB_CAPABLE, GLFW_FALSE) // TODO: make this a parameter

        // Reset mode specific values
        glfwWindowHint(GLFW_RED_BITS, GLFW_DONT_CARE)
        glfwWindowHint(GLFW_GREEN_BITS, GLFW_DONT_CARE)
        glfwWindowHint(GLFW_BLUE_BITS, GLFW_DONT_CARE)
        glfwWindowHint(GLFW_REFRESH_RATE, GLFW_DONT_CARE)

        // Resize mode
        glfwWindowHint(GLFW_RESIZABLE, GLFW_FALSE) // TODO: set to `true` or `false` depending on requested settings

        // Get monitor and mode
        let monitor = glfwGetPrimaryMonitor()

        if monitor == nil {
            throw GLFWError.noPrimaryMonitor
        }

        guard let videoMode = glfwGetVideoMode(monitor) else {
            throw GLFWError.noVideoMode
        }

        // Create the window
        let window: OpaquePointer?
        switch mode {
            // Windowed mode
            case let .windowed(width, height):
                window = glfwCreateWindow(
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

                window = glfwCreateWindow(
                    videoMode.pointee.width,
                    videoMode.pointee.height,
                    title,
                    monitor,
                    nil
                )
            // Fullscreen mode
            case .fullscreen:
                window = glfwCreateWindow(
                    videoMode.pointee.width,
                    videoMode.pointee.height,
                    title,
                    monitor,
                    nil
                )
        }

        guard let window else {
            throw GLFWError.cannotCreateWindow
        }

        self.window = window

        // Create the resources window
        glfwWindowHint(GLFW_DECORATED, GLFW_FALSE)
        glfwWindowHint(GLFW_VISIBLE, GLFW_FALSE)
        let resourcesWindow = glfwCreateWindow(1, 1, "", nil, window)

        guard let resourcesWindow else {
            throw GLFWError.cannotCreateWindow
        }

        self.resourceWindow = resourcesWindow

        // Initialize graphics API
        glfwMakeContextCurrent(window)
        gladLoadGLLoaderFromGLFW()

        // GL Debug
        glEnable(GLenum(GL_DEBUG_OUTPUT))
        glDebugMessageCallback({ source, type, id, severity, length, message, userParam in
            if let message {
                print("OpenGL ERROR \(id): \(String(cString: message))")
            } else {
                print("OpenGL ERROR \(id)")
            }
        }, nil)

        // TODO: Enable sRGB if requested

        // Set state
        var actualWindowWidth: Int32 = 0
        var actualWindowHeight: Int32 = 0
        glfwGetWindowSize(window, &actualWindowWidth, &actualWindowHeight)

        self.size = WindowSize(width: Int(actualWindowWidth), height: Int(actualWindowHeight))

        // Finalize init
        // Flutter Engine will make the context current again on its own UI thread
        glfwMakeContextCurrent(nil)
    }

    func makeContextCurrent() {
        glfwMakeContextCurrent(self.window)
    }

    func clearContext() {
        glfwMakeContextCurrent(nil)
    }

    func makeResourcesContextCurrent() {
        glfwMakeContextCurrent(self.resourceWindow)
    }

    func swapBuffers() {
        glfwSwapBuffers(self.window)
    }

    func onPlatformMessage(_ message: FlutterPlatformMessage) {
        guard let engine else { return }

        let channel = String(cString: message.channel)
        print("Received platform message '\(String(cString: message.message, length: message.message_size))' on channel '\(channel)'")

        // TODO: implement calls instead of reporting failure every time
        FlutterEngineSendPlatformMessageResponse(engine, message.response_handle, nil, 0)
    }

    func start() throws -> Never {
        guard FlutterEngineRunsAOTCompiledDartCode() else {
            fatalError("Flutter Engine was compiled without AOT support, cannot continue")
        }

        // Create renderer config
        var config = FlutterRendererConfig()
        config.type = kOpenGL
        config.open_gl.struct_size = MemoryLayout.size(ofValue: config.open_gl)

        config.open_gl.make_current = { userdata in
            guard let userdata else { fatalError("'make_current' called with no userdata") }
            let window = Unmanaged<GLFWWindow>.fromOpaque(userdata).takeUnretainedValue()
            window.makeContextCurrent()
            return true
        }

        config.open_gl.clear_current = { userdata in
            guard let userdata else { fatalError("'clear_current' called with no userdata") }
            let window = Unmanaged<GLFWWindow>.fromOpaque(userdata).takeUnretainedValue()
            window.clearContext()
            return true
        }

        config.open_gl.present = { userdata in
            guard let userdata else { fatalError("'present' called with no userdata") }
            let window = Unmanaged<GLFWWindow>.fromOpaque(userdata).takeUnretainedValue()
            window.swapBuffers()
            return true
        }

        config.open_gl.make_resource_current = { userdata in
            guard let userdata else { fatalError("'make_resource_current' called with no userdata") }
            let window = Unmanaged<GLFWWindow>.fromOpaque(userdata).takeUnretainedValue()
            window.makeResourcesContextCurrent()
            return true
        }

        config.open_gl.fbo_callback = { _ in
            return 0 // FBO0
        }

        config.open_gl.gl_proc_resolver = { _, name in
            return getProcAddress(name)
        }

        // Create args
        // Don't forget to free all strings after `FlutterEngineRun`
        // TODO: put everything in a bundle, including libapp.so
        let assetsPath = strdup("/home/natinusala/ScarletUI/Sources/Renderer/Host/build/linux/x64/release/bundle/data/flutter_assets")
        let icudtlPath = strdup("/home/natinusala/ScarletUI/Sources/Renderer/Host/build/linux/x64/release/bundle/data/icudtl.dat")

        var args = FlutterProjectArgs()
        args.struct_size = MemoryLayout.size(ofValue: args)

        // Paths
        args.assets_path = UnsafePointer(assetsPath)
        args.icu_data_path = UnsafePointer(icudtlPath)

        // AOT data from libapp.so ELF
        "/home/natinusala/ScarletUI/Sources/Renderer/Host/build/linux/x64/release/bundle/lib/libapp.so".withCString { elfPath in
            var aotDataSource = FlutterEngineAOTDataSource()
            aotDataSource.type = kFlutterEngineAOTDataSourceTypeElfPath
            aotDataSource.elf_path = elfPath
            guard FlutterEngineCreateAOTData(&aotDataSource, &args.aot_data) == kSuccess, args.aot_data != nil else {
                fatalError("'FlutterEngineCreateAOTData' failed")
            }
        }

        // Callbacks
        args.platform_message_callback = { message, userdata in
            guard let userdata else { fatalError("'platform_message_callback' called with no userdata") }
            guard let message else { return }
            let window = Unmanaged<GLFWWindow>.fromOpaque(userdata).takeUnretainedValue()
            window.onPlatformMessage(message.pointee)
        }

        // Run the engine
        // The Swift window is retained by the engine
        let userdata = Unmanaged.passRetained(self)

        guard FLUTTER_ENGINE_VERSION == flutterEmbedderVersion else {
            fatalError("Wrong Flutter Engine version - ScarletUI renderer needs Embedder API \(flutterEmbedderVersion) but has been compiled with version \(FLUTTER_ENGINE_VERSION) (defined in 'flutter_embedder.h')")
        }

        let result = FlutterEngineRun(
            flutterEmbedderVersion,
            &config,
            &args,
            userdata.toOpaque(),
            &self.engine
        )

        free(assetsPath)
        free(icudtlPath)

        guard result == kSuccess, engine != nil else {
            throw FlutterEngineError.engineRunFailed
        }

        // Give Flutter the initial window size
        // TODO: Setup GLFW callback and call that instead of putting the code here
        var event = FlutterWindowMetricsEvent()
        event.struct_size = MemoryLayout.size(ofValue: event)
        event.width = self.size.width
        event.height = self.size.height
        event.pixel_ratio = 1
        FlutterEngineSendWindowMetricsEvent(engine, &event)

        // Run
        while glfwWindowShouldClose(self.window) == 0 {}

        // Shutdown
        FlutterEngineShutdown(engine)

        userdata.release()

        glfwDestroyWindow(self.window);
        glfwDestroyWindow(self.resourceWindow);
        glfwTerminate();

        exit(0)
    }
}

/// GLFW errors.
enum GLFWError: Error {
    case initFailed
    case noPrimaryMonitor
    case noVideoMode
    case cannotCreateWindow
}

enum FlutterEngineError: Error {
    case engineRunFailed
}
