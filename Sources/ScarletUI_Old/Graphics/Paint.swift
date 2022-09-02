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

public enum FilteringQuality {
    /// Nearest pixel.
    case none

    /// Bilinear filtering.
    case low

    /// Bilinear filtering with mipmaps for downscaling.
    case medium

    /// Bicubic filtering.
    case high

    var skFilterQuality: sk_filter_quality_t {
        switch self {
            case .none:
                return NONE_SK_FILTER_QUALITY
            case .low:
                return LOW_SK_FILTER_QUALITY
            case .medium:
                return MEDIUM_SK_FILTER_QUALITY
            case .high:
                return HIGH_SK_FILTER_QUALITY
        }
    }
}

/// A paint represents the aspect and style of everything drawn onscreen. It can be
/// an image, a color, it can have effects...
public class Paint {
    public let handle: OpaquePointer

    /// Creates a paint with default values.
    public init() {
        self.handle = sk_paint_new()
    }

    /// Creates a paint with given color.
    public convenience init(color: Color) {
        self.init()

        self.setColor(color)
    }

    /// Creates a paint with given shader.
    public convenience init(shader: Shader) {
        self.init()

        self.setShader(shader)
    }

    /// Attempts to create a paint with given optional color.
    /// Will return `nil` if the color is `nil`.
    public convenience init?(color: Color?) {
        if let color = color {
            self.init(color: color)
        }

        return nil
    }

    /// Sets the paint color.
    public func setColor(_ color: Color) {
        sk_paint_set_color(self.handle, color.value)
    }

    /// Sets the paint shader.
    public func setShader(_ shader: Shader) {
        sk_paint_set_shader(self.handle, shader.handle)
    }

    /// Sets the filtering quality.
    public func setFilteringQuality(_ quality: FilteringQuality) {
        sk_paint_set_filter_quality(self.handle, quality.skFilterQuality)
    }

    deinit {
        sk_paint_delete(self.handle)
    }
}
