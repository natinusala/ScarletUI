/*
    Copyright 2021 natinusala

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

/// A percentage value. Internally contains a float between 0 and 1.
public struct Percentage: Equatable {
    public let value: Float

    /// Creates a percentage from the given 0 to 100 integer.
    public init(_ int: Int) {
        self.value = Float(int) / 100.0
    }

    /// Creates a percentage from the given 0 to 1 float.
    public init(_ float: Float) {
        self.value = Float(float)
    }
}

/// A display-independent pixel is the unit used for views after scaling is applied.
public struct DIP: Equatable, ExpressibleByFloatLiteral, ExpressibleByIntegerLiteral, CustomStringConvertible {
    public let value: Float

    public init(_ value: Float) {
        self.value = value
    }

    public init(floatLiteral value: Float) {
        self.value = value
    }

    public init(integerLiteral value: Int) {
        self.value = Float(value)
    }

    public var description: String {
        return String(describing: self.value)
    }
}

/// Percentage postfix operator, used to convert integers to `Percentage`.
postfix operator %

public extension IntegerLiteralType {
    /// Integer percentage "literal", converts a 0 to 100 integer to a
    /// `Percentage`.
    static postfix func % (int: Int) -> Percentage {
        return Percentage(int)
    }
}

public extension Int {
    /// Converts the integer into a DIP.
    var dip: DIP {
        return DIP(Float(self))
    }
}

public extension Float {
    /// Converts the float into a DIP.
    var dip: DIP {
        return DIP(self)
    }
}

public struct DIP4: Equatable {
    var top: DIP = 0
    var right: DIP = 0
    var bottom: DIP = 0
    var left: DIP = 0
}
