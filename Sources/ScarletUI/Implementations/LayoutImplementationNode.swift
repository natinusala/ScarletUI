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
    /// Underlying Yoga node.
    var ygNode: YGNodeRef { get }

    /// The computed layout.
    var layout: Rect { get set }

    /// Node parent as a `LayoutImplementationNode`.
    var layoutParent: LayoutImplementationNode? { get }

    /// Node children as `LayoutImplementationNode`.
    var layoutChildren: [LayoutImplementationNode] { get }

    var axis: Axis { get set }
}

public extension LayoutImplementationNode {
    /// Runs a layout pass if the node is dirty.
    /// Should be called every frame before drawing the node.
    func layoutIfNeeded() {
        if YGNodeIsDirty(self.ygNode) {
            Logger.debug(true, "\(self) is dirty, calculating layout")
            self.calculateLayout()
        }
    }

    /// Calculates layout of this element, either by calculating layout of its parent
    /// or calculating its layout directly if the element doesn't have a parent.
    private func calculateLayout() {
        if let parent = self.layoutParent {
            parent.calculateLayout()
        } else {
            Logger.debug(true, "Calling `YGNodeCalculateLayout` on \(self)")

            // Use Yoga to calculate layout
            YGNodeCalculateLayout(self.ygNode, YGUndefined, YGUndefined, YGDirectionLTR)

            // Propagate newly calculated layout to our properties and all our children
            self.updateLayout(parentX: 0, parentY: 0)
        }
    }

    /// Called when the parent view layout changes.
    private func updateLayout(parentX: Float, parentY: Float) {
        self.layout = Rect(
            x: parentX + YGNodeLayoutGetLeft(self.ygNode),
            y: parentY + YGNodeLayoutGetTop(self.ygNode),
            width: YGNodeLayoutGetWidth(self.ygNode),
            height: YGNodeLayoutGetHeight(self.ygNode)
        )

        Logger.debug(true, "New layout of \(self): \(self.layout)")

        for child in self.layoutChildren {
            child.updateLayout(parentX: self.layout.x, parentY: self.layout.y)
        }
    }
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
