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

import Foundation

/// A desktop window.
/// Views are arranged in a column by default.
public struct Window<Content>: StatelessLeafScene where Content: View {
    public typealias Implementation = _WindowImplementation

    @Attribute(\_WindowImplementation.title)
    var title

    @Attribute(\_WindowImplementation.mode)
    var mode

    public let content: Content

    public init(
        title: String? = nil,
        mode: WindowMode? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.content = content()

        self.$title.setFromOptional(title)
        self.$mode.setFromOptional(mode)
    }
}

public class _WindowImplementation: _SceneImplementation {
    /// The window title.
    var title = ""

    /// The window mode.
    var mode = WindowMode.getDefault()

    /// The window graphics backend.
    var backend = GraphicsBackend.getDefault()

    /// Whether to use sRGB color space or not.
    var srgb: Bool = false

    /// The native window handle.
    var handle: _NativeWindow?

    /// The canvas used by all views to draw themselves.
    var canvas: Canvas? {
        return self.handle?.context.canvas
    }

    public override func create(platform: _Platform) {
        do {
            // Create the native window
            let handle = try platform.createWindow(
                title: self.title,
                mode: self.mode,
                backend: self.backend,
                srgb: self.srgb
            )
            self.handle = handle

            graphicsLogger.info("Created new \(handle.size.width)x\(handle.size.height) window (mode: \(self.mode.name))")

            // Set the initial node dimensions
            self.windowDidResize()
        } catch {
            graphicsLogger.error("Unable to create window: \(error)")
            exit(-1)
        }
    }

    override public func frame() -> Bool {
        self.layoutIfNeeded()

        if let handle = self.handle {
            // Clear
            let clearPaint = Paint(color: Color.black)
            self.canvas?.drawPaint(clearPaint)

            // Draw every view
            for view in self.children {
                view.frame(canvas: self.canvas)
            }

            // Swap buffers
            handle.swapBuffers()

            return handle.shouldClose
        }

        return false
    }

    /// Called after the window gets resized by the user.
    func windowDidResize() {
        if let handle = self.handle {
            self.desiredSize = Size(width: handle.size.width.dip, height: handle.size.height.dip)
        }
    }

    public override func pollGamepad() -> _GamepadState {
        if let handle = self.handle {
            return handle.pollGamepad()
        }

        return .neutral
    }

    public var description: String {
        return "Window(title: \"\(self.title)\", mode: \(self.mode))"
    }
}
