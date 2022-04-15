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

/// A dummy platform that does nothing.
class DummyPlatform: Platform {
    required init() {}

    let name = "Dummy"

    func poll() {}

    func createWindow(title: String, mode: WindowMode, backend: GraphicsBackend) throws -> NativeWindow {
        return DummyWindow(mode: mode)
    }
}

/// A dummy window.
class DummyWindow: NativeWindow {
    let mode: WindowMode

    init(mode: WindowMode) {
        self.mode = mode
    }

    var shouldClose: Bool { return false }

    var size: Size {
        switch self.mode {
            case .windowed(let width, let height):
                return (width, height)
            case .borderless, .fullscreen:
                return (1280, 720)
        }
    }

    func swapBuffers() {}
}
