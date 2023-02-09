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

// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation

import FlutterEngine
import Glad
import GLFW

import CRenderer

// TODO: reinstate Logger and remove fatalErrors / use exceptions if possible
// TODO: yeet HostAppLib

/// A renderer instance backed by a GLFW window.
class GLFWWindow: Window {
    let delegate: WindowDelegate
    let windowHandle: OpaquePointer

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

        // Create the new window
        let handle: OpaquePointer?
        switch mode {
            // Windowed mode
            case let .windowed(width, height):
                handle = glfwCreateWindow(
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

                handle = glfwCreateWindow(
                    videoMode.pointee.width,
                    videoMode.pointee.height,
                    title,
                    monitor,
                    nil
                )
            // Fullscreen mode
            case .fullscreen:
                handle = glfwCreateWindow(
                    videoMode.pointee.width,
                    videoMode.pointee.height,
                    title,
                    monitor,
                    nil
                )
        }

        guard let handle else {
            throw GLFWError.cannotCreateWindow
        }

        self.windowHandle = handle

        // Initialize graphics API
        glfwMakeContextCurrent(handle)
        gladLoadGLLoaderFromGLFW()

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
        glfwGetWindowSize(handle, &actualWindowWidth, &actualWindowHeight)

        self.size = WindowSize(width: Int(actualWindowWidth), height: Int(actualWindowHeight))

        // Finalize init
        // Flutter Engine will make the context current again on its own UI thread
        glfwSwapInterval(1)
        glfwMakeContextCurrent(nil)
    }

    func makeContextCurrent() {
        glfwMakeContextCurrent(self.windowHandle)
    }

    func clearContext() {
        glfwMakeContextCurrent(nil)
    }

    func swapBuffers() {
        glfwSwapBuffers(self.windowHandle)
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

        config.open_gl.fbo_callback = { _ in
            return 0 // FBO0
        }

        config.open_gl.gl_proc_resolver = { _, name in
            return getProcAddress(name)
        }

        // Create args
        // Don't forget to free all strings after `FlutterEngineRun`
        // TODO: put everything in a bundle, including libapp.so
        let assetsPath = strdup("/home/natinusala/ScarletUI/Sources/Renderer/Host/build/linux/x64/profile/bundle/data/flutter_assets")
        let icudtlPath = strdup("/home/natinusala/ScarletUI/Sources/Renderer/Host/build/linux/x64/profile/bundle/data/icudtl.dat")

        var args = FlutterProjectArgs()
        args.struct_size = MemoryLayout.size(ofValue: args)

        // Paths
        args.assets_path = UnsafePointer(assetsPath)
        args.icu_data_path = UnsafePointer(icudtlPath)

        // AOT data from libapp.so ELF
        "/home/natinusala/ScarletUI/Sources/Renderer/Host/build/linux/x64/profile/bundle/lib/libapp.so".withCString { elfPath in
            var aotDataSource = FlutterEngineAOTDataSource()
            aotDataSource.type = kFlutterEngineAOTDataSourceTypeElfPath
            aotDataSource.elf_path = elfPath
            guard FlutterEngineCreateAOTData(&aotDataSource, &args.aot_data) == kSuccess, args.aot_data != nil else {
                fatalError("'FlutterEngineCreateAOTData' failed")
            }
        }

        // Run the engine
        // The Swift window is indefinitely retained by the engine
        let userdata = Unmanaged.passRetained(self).toOpaque()

        var engine: FlutterEngine? = nil
        assert(FLUTTER_ENGINE_VERSION == flutterEmbedderVersion)
        let result = FlutterEngineRun(
            flutterEmbedderVersion,
            &config,
            &args,
            userdata,
            &engine
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

        // Pump GLFW events
        while glfwWindowShouldClose(self.windowHandle) == 0 {
            glfwWaitEvents()
        }

        FlutterEngineShutdown(engine)

        glfwDestroyWindow(self.windowHandle);
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
