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

/// An ARGB color.
public struct Color: CustomStringConvertible, Equatable {
    public static let white = Color(r: 255, g: 255, b: 255)
    public static let black = Color(r: 0, g: 0, b: 0)
    public static let red = Color(r: 255, g: 0, b: 0)
    public static let green = Color(r: 0, g: 255, b: 0)
    public static let blue = Color(r: 0, g: 0, b: 255)
    public static let yellow = Color(r: 255, g: 255, b: 0)
    public static let orange = Color(r: 255, g: 165, b: 0)

    /// ARGB value.
    public let value: UInt32

    /// Creates a color with given RGB values. Alpha will be set to 255 (fully opaque).
    public init(r: UInt8, g: UInt8, b: UInt8) {
        self.init(a: 255, r: r, g: g, b: b)
    }

    /// Creates a color with given ARGB values. Assumes given value are all
    /// between 0 and 255.
    public init(a: UInt8, r: UInt8, g: UInt8, b: UInt8) {
        self.value = (UInt32(a) << 24) |
            (UInt32(r) << 16) |
            (UInt32(g) << 8) |
            (UInt32(b) << 0)
    }

    /// Creates a color with given ARGB UInt32 value.
    public init(argb value: UInt32) {
        self.value = value
    }

    /// Creates a color with given RGB UInt32 value. Alpha will be set to 255 (fully opaque).
    public init(rgb value: UInt32) {
        self.init(argb: value | 0xFF000000)
    }

    public var description: String {
        return String(format: "0x%08X", self.value)
    }

    public static func == (lhs: Color, rhs: Color) -> Bool {
        return lhs.value == rhs.value
    }

    /// Makes a random color with full opacity.
    public static var random: Self {
        return Color(
            r: UInt8.random(in: 0...255),
            g: UInt8.random(in: 0...255),
            b: UInt8.random(in: 0...255)
        )
    }
}
