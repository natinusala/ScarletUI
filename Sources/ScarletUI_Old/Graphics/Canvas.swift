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

/// A canvas is the handle used to draw everything onscreen.
public protocol Canvas {
    /// Draws the given paint on the whole canvas.
    func drawPaint(_ paint: Paint)

    /// Draws the given paint in the given rectangle region.
    func drawRect(
        _ rect: Rect,
        paint: Paint
    )
}

public class SkiaCanvas: Canvas {
    let handle: OpaquePointer

    init(handle: OpaquePointer) {
        self.handle = handle
    }

    public func drawPaint(_ paint: Paint) {
        sk_canvas_draw_paint(self.handle, paint.handle)
    }

    public func drawRect(
        _ rect: Rect,
        paint: Paint
    ) {
        var skiaRect = rect.skRect
        sk_canvas_draw_rect(
            self.handle,
            &skiaRect,
            paint.handle
        )
    }
}
