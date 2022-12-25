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

import Yoga

/// Percentage postfix operator, used to convert integers to `Percentage`.
postfix operator %

public extension IntegerLiteralType {
    /// Integer percentage "literal", converts any 0 to 100 integer to a
    /// percentage value.
    static postfix func % (int: Int) -> LayoutValue {
        return .percentage(value: Float(int))
    }
}

public extension FloatLiteralType {
    /// Float percentage "literal", converts any 0 to 100 integer to a
    /// percentage value.
    static postfix func % (double: Double) -> LayoutValue {
        return .percentage(value: Float(double))
    }
}

/// Contains values for all 4 edges of a view.
public struct LayoutEdgesValues: Equatable {
    let top: LayoutValue
    let right: LayoutValue
    let bottom: LayoutValue
    let left: LayoutValue
}

/// Represents a value of a specific unit.
public enum LayoutValue: Equatable, ExpressibleByIntegerLiteral, ExpressibleByFloatLiteral {
    /// Let the framework decide the value to have a
    /// balanced layout.
    case auto

    /// A display independent pixel.
    case dip(value: Float)

    /// A percentage value ranging from 0 to 100.
    case percentage(value: Float)

    /// Let the framework set any value without any rules
    /// or balancing constraints.
    case undefined

    public init(integerLiteral: Int) {
        self = .dip(value: Float(integerLiteral))
    }

    public init(floatLiteral: Float) {
        self = .dip(value: floatLiteral)
    }

    /// Human readable unit name.
    public var unitName: String {
        switch self {
            case .auto:
                return "auto"
            case .dip:
                return "dip"
            case .percentage:
                return "percentage"
            case .undefined:
                return "undefined"
        }
    }

    static func fromYGValue(_ value: YGValue) -> LayoutValue {
        switch value.unit {
            case YGUnitUndefined:
                return .undefined
            case YGUnitAuto:
                return .auto
            case YGUnitPoint:
                return .dip(value: value.value)
            case YGUnitPercent:
                return .percentage(value: value.value)
            default:
                fatalError("Unsupported `YGUnit` \(value.unit)")
        }
    }
}

/// Width and height of a view.
public struct Size: Equatable {
    let width: LayoutValue
    let height: LayoutValue
}

public extension Float {
    /// Converts a `Float` to a `Value` with `dip` unit.
    var dip: LayoutValue {
        return .dip(value: self)
    }

    /// Converts a `Float` to a `Value` with `percentage` unit.
    var percentage: LayoutValue {
        return .percentage(value: self)
    }
}
