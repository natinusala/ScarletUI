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

public struct HeadlessPlatform: _Platform {
    public let name = "Headless"

    public init() {}

    public func pollEvents() {}

    public func createWindow(title: String, mode: ScarletUI.WindowMode, backend: ScarletUI.GraphicsBackend, srgb: Bool) throws -> _NativeWindow {
        guard case .windowed(let width, let height) = mode else {
            fatalError("Headless platform can only be used with windowed mode")
        }

        return HeadlessWindow(size: (width: width, height: height), context: HeadlessContext())
    }

    public func openBrowser(for url: String) throws {
        throw PlatformError.unimplemented
    }
}

struct HeadlessWindow: _NativeWindow {
    var shouldClose = false
    var position: (x: Int, y: Int)? = (x: 0, y: 0)

    var size: WindowSize
    var context: _GraphicsContext

    init(size: WindowSize, context: _GraphicsContext) {
        self.size = size
        self.context = context
    }

    func swapBuffers() {}

    func pollGamepad(previousState: _GamepadState) -> ScarletUI._GamepadState {
        return .neutral
    }
}

struct HeadlessContext: _GraphicsContext {
    let canvas: any Canvas = HeadlessCanvas()
}

struct HeadlessCanvas: Canvas {
    func drawPaint(_ paint: ScarletUI.Paint) {}
    func drawRect(_ rect: ScarletUI.Rect, paint: ScarletUI.Paint) {}
}
