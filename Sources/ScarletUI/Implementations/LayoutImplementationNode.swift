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

/// An implementation node that has layout properties.
public protocol LayoutImplementationNode: ImplementationNode, AnyObject {
    var axis: Axis { get set }
}

/// The "axis", aka. the direction in which children are laid out.
public enum Axis {
    /// Column (vertical) axis.
    case column

    /// Reversed column (vertical) axis.
    case columnReverse

    /// Row (horizontal) axis.
    case row

    /// Reversed row (horizontal) axis.
    case rowReverse

    /// Associated Yoga flex direction.
    var ygFlexDirection: YGFlexDirection {
        switch self {
            case .column:
                return YGFlexDirectionColumn
            case .columnReverse:
                return YGFlexDirectionColumnReverse
            case .row:
                return YGFlexDirectionRow
            case .rowReverse:
                return YGFlexDirectionRowReverse
        }
    }
}

public extension YGFlexDirection {
    var axis: Axis {
        switch self {
            case YGFlexDirectionColumn:
                return .column
            case YGFlexDirectionColumnReverse:
                return .columnReverse
            case YGFlexDirectionRow:
                return .row
            case YGFlexDirectionRowReverse:
                return .rowReverse
            default:
                fatalError("Unknown `YGFlexDirection` \(self)")
        }
    }
}
