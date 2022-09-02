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

/// A 3x3 matrix.
public struct Matrix {
    var handle: sk_matrix_t

    private init(handle: sk_matrix_t) {
        self.handle = handle
    }

    /// Creates a new identity matrix.
    public static func identity() -> Matrix {
        let handle = sk_matrix_t(
            scaleX: 1.0, skewX: 0.0, transX: 0.0,
            skewY: 0.0, scaleY: 1.0, transY: 0.0,
            persp0: 0.0, persp1: 0.0, persp2: 1.0
        )

        return Matrix(handle: handle)
    }

    /// Returns a new matrix scaled by sx and sy, about a pivot point at (px, py).
    public func scale(sx: Float, sy: Float, px: Float, py: Float) -> Matrix {
        var src = self.handle
        var dst = sk_matrix_t()

        sk_matrix_scale_about_pivot(
            &src,
            &dst,
            sx,
            sy,
            px,
            py
        )

        return Matrix(handle: dst)
    }
}
