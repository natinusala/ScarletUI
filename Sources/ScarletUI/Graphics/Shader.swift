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

/// A shader describes the color(s) to use for a paint. It replaces the paint "base" color.
public struct Shader {
    let handle: OpaquePointer

    private init(handle: OpaquePointer) {
        self.handle = handle
    }

    /// Creates a new shader with the given radial gradient.
    public static func radialGradient(
        center: (x: Float, y: Float),
        radius: (h: Float, v: Float),
        colors: [(Color, Float)]
    ) -> Shader {
        var point = sk_point_t(x: center.x, y: center.y)
        var colorPos = colors.map { $0.1 }
        var colors = colors.map { $0.0.value }

        var matrix = Matrix.identity().scale(sx: radius.h, sy: radius.v, px: center.x, py: center.y)

        let handle = sk_shader_new_radial_gradient(&point, 1, &colors, &colorPos, Int32(colors.count), CLAMP_SK_SHADER_TILEMODE, &matrix.handle)

        guard let handle = handle else {
            fatalError("Cannot create radial gradient shader: `sk_shader_new_radial_gradient` returned NULL")
        }

        return Shader(handle: handle)
    }
}
