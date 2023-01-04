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

/// Represents an immutable graphics context tied to a window, with fixed width, height and backend.
/// The canvas used everywhere by the app is a product of this context.
/// This is different from the underlying backend context (OpenGL...).
public protocol _GraphicsContext {
    /// Canvas to be used to draw on this context.
    var canvas: Canvas { get }
}

/// TODO: put stuff that needs teardown in a wrapper class for deinit
public struct _SkiaContext: _GraphicsContext {
    /// Skia context of this graphics context.
    let skContext: OpaquePointer

    public let canvas: Canvas

    /// Graphics backend of this context.
    let backend: GraphicsBackend

    /// Creates a new immutable graphics context.
    ///
    /// The window context must be made current and backend
    /// symbols must be fully loaded by the caller before creating a
    /// new context.
    init(width: Float, height: Float, backend: GraphicsBackend, srgb: Bool) throws {
        self.backend = backend

        var backendRenderTarget: OpaquePointer?
        var context: OpaquePointer?

        switch backend {
            case .gl:
                let interface = gr_glinterface_create_native_interface()
                context = gr_direct_context_make_gl(interface)

                var framebufferInfo = gr_gl_framebufferinfo_t(
                    fFBOID: 0,
                    fFormat: UInt32(srgb ? GL_SRGB8_ALPHA8 : GL_RGBA8)
                )

                backendRenderTarget = gr_backendrendertarget_new_gl(
                    Int32(width),
                    Int32(height),
                    0,
                    0,
                    &framebufferInfo
                )
        }

        guard let context = context else {
            throw GraphicsContextError.cannotInitSkiaContext
        }

        self.skContext = context

        guard let target = backendRenderTarget else {
            throw GraphicsContextError.cannotInitSkiaTarget
        }

        let colorSpace: OpaquePointer? = srgb ? sk_colorspace_new_srgb() : nil

        let surface = sk_surface_new_backend_render_target(
            context,
            target,
            BOTTOM_LEFT_GR_SURFACE_ORIGIN,
            RGBA_8888_SK_COLORTYPE,
            colorSpace,
            nil
        )

        if surface == nil {
            throw GraphicsContextError.cannotInitSkiaSurface
        }

        graphicsLogger.info("Created \(backend.name) context:")
        graphicsLogger.info("   - Size: \(width)x\(height)")

        switch backend {
            case .gl:
                var majorVersion: GLint = 0
                var minorVersion: GLint = 0
                glGetIntegerv(GLenum(GL_MAJOR_VERSION), &majorVersion)
                glGetIntegerv(GLenum(GL_MINOR_VERSION), &minorVersion)

                graphicsLogger.info("   - Version: \(majorVersion).\(minorVersion)")
                graphicsLogger.info("   - GLSL version: \(String(cString: glGetString(GLenum(GL_SHADING_LANGUAGE_VERSION))!))")
        }

        guard let nativeCanvas = sk_surface_get_canvas(surface) else {
            throw GraphicsContextError.cannotInitSkiaCanvas
        }

        self.canvas = _SkiaCanvas(handle: nativeCanvas)
    }
}

/// The graphics backend of an application.
public enum GraphicsBackend {
    /// OpenGL.
    case gl

    /// Selects the best available graphics API, or fatals if none was found.
    public static func getDefault() -> GraphicsBackend {
        // TODO: only return OpenGL if it's actually available
        return .gl
    }

    /// Full, human-redable name.
    var name: String {
        switch self {
            case .gl:
                return "OpenGL"
        }
    }
}

/// Errors that can occur while creating a new graphics context.
enum GraphicsContextError: Error {
    case cannotInitSkiaSurface
    case cannotInitSkiaTarget
    case cannotInitSkiaContext
    case cannotInitSkiaCanvas
}
