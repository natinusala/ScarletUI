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

import ScarletCore

/// Implementation for all views.
open class ViewImplementation: ImplementationNode, CustomStringConvertible {
    /// View display name for debugging purposes.
    let displayName: String

    /// Children of this view.
    var children: [ViewImplementation] = []

    /// The view Yoga node.
    let ygNode: YGNodeRef

    /// The node axis.
    var axis: Axis {
        get {
            return YGNodeStyleGetFlexDirection(self.ygNode).axis
        }
        set {
            YGNodeStyleSetFlexDirection(self.ygNode, newValue.ygFlexDirection)
        }
    }

    /// The view padding, aka. the space between this view and its children.
    var padding: EdgesValues {
        get {
            return EdgesValues(
                top: .fromYGValue(YGNodeStyleGetPadding(self.ygNode, YGEdgeTop)),
                right: .fromYGValue(YGNodeStyleGetPadding(self.ygNode, YGEdgeRight)),
                bottom: .fromYGValue(YGNodeStyleGetPadding(self.ygNode, YGEdgeBottom)),
                left: .fromYGValue(YGNodeStyleGetPadding(self.ygNode, YGEdgeLeft))
            )
        }
        set {
            switch newValue.top {
                case let .dip(value):
                    YGNodeStyleSetPadding(self.ygNode, YGEdgeTop, value)
                case let .percentage(percentage):
                    YGNodeStyleSetPaddingPercent(self.ygNode, YGEdgeTop, percentage)
                case .undefined:
                    YGNodeStyleSetPadding(self.ygNode, YGEdgeTop, YGUndefined)
                case .auto:
                    fatalError("Invalid unit \(newValue.top.unitName) for padding")
            }

            switch newValue.right {
                case let .dip(value):
                    YGNodeStyleSetPadding(self.ygNode, YGEdgeRight, value)
                case let .percentage(percentage):
                    YGNodeStyleSetPaddingPercent(self.ygNode, YGEdgeRight, percentage)
                case .undefined:
                    YGNodeStyleSetPadding(self.ygNode, YGEdgeTop, YGUndefined)
                case .auto:
                    fatalError("Invalid unit \(newValue.right.unitName) for padding")
            }

            switch newValue.bottom {
                case let .dip(value):
                    YGNodeStyleSetPadding(self.ygNode, YGEdgeBottom, value)
                case let .percentage(percentage):
                    YGNodeStyleSetPaddingPercent(self.ygNode, YGEdgeBottom, percentage)
                case .undefined:
                    YGNodeStyleSetPadding(self.ygNode, YGEdgeTop, YGUndefined)
                case .auto:
                    fatalError("Invalid unit \(newValue.bottom.unitName) for padding")
            }

            switch newValue.left {
                case let .dip(value):
                    YGNodeStyleSetPadding(self.ygNode, YGEdgeLeft, value)
                case let .percentage(percentage):
                    YGNodeStyleSetPaddingPercent(self.ygNode, YGEdgeLeft, percentage)
                case .undefined:
                    YGNodeStyleSetPadding(self.ygNode, YGEdgeTop, YGUndefined)
                case .auto:
                    fatalError("Invalid unit \(newValue.left.unitName) for padding")
            }
        }
    }

    /// The desired size of the view.
    ///
    /// The actual size after layout may or may not be the desired size,
    /// however it cannot be less than the desired size.
    var desiredSize: Size {
        get {
            return Size(
                width: .fromYGValue(YGNodeStyleGetWidth(self.ygNode)),
                height: .fromYGValue(YGNodeStyleGetHeight(self.ygNode))
            )
        }
        set {
            switch newValue.width {
                case let .dip(value):
                    YGNodeStyleSetWidth(self.ygNode, value)
                    YGNodeStyleSetMinWidth(self.ygNode, value)
                case let .percentage(percentage):
                    YGNodeStyleSetWidthPercent(self.ygNode, percentage)
                    YGNodeStyleSetMinWidthPercent(self.ygNode, percentage)
                case .auto:
                    YGNodeStyleSetWidthAuto(self.ygNode)
                    YGNodeStyleSetMinWidth(self.ygNode, YGUndefined)
                case .undefined:
                    YGNodeStyleSetWidth(self.ygNode, YGUndefined)
                    YGNodeStyleSetMinWidth(self.ygNode, YGUndefined)
            }

            switch newValue.height {
                case let .dip(value):
                    YGNodeStyleSetHeight(self.ygNode, value)
                    YGNodeStyleSetMinHeight(self.ygNode, value)
                case let .percentage(percentage):
                    YGNodeStyleSetHeightPercent(self.ygNode, percentage)
                    YGNodeStyleSetMinHeightPercent(self.ygNode, percentage)
                case .auto:
                    YGNodeStyleSetHeightAuto(self.ygNode)
                    YGNodeStyleSetMinHeight(self.ygNode, YGUndefined)
                case .undefined:
                    YGNodeStyleSetHeight(self.ygNode, YGUndefined)
                    YGNodeStyleSetMinHeight(self.ygNode, YGUndefined)
            }
        }
    }

    public required init(kind: ImplementationKind, displayName: String) {
        guard kind == .view else {
            fatalError("Tried to create a `ViewImplementation` with kind \(kind)")
        }

        self.displayName = displayName

        self.ygNode = YGNodeNew()
    }

    deinit {
        YGNodeFree(self.ygNode)
    }

    public func insertChild(_ child: ImplementationNode, at position: Int) {
        guard let child = child as? ViewImplementation else {
            fatalError("Cannot add \(type(of: child)) as child of `ViewImplementation`")
        }

        self.children.insert(child, at: position)
    }

    public func removeChild(at position: Int) {
        self.children.remove(at: position)
    }

    open func attributesDidSet() {
        // Nothing by default
    }

    public func printTree(indent: Int = 0) {
        let indentString = String(repeating: " ", count: indent)
        print("\(indentString)- \(self.description) (\(Self.self))")

        for child in self.children {
            child.printTree(indent: indent + 4)
        }
    }

    public var description: String {
        return self.displayName
    }
}

public extension View {
    /// Default implementation for user views.
    typealias Implementation = ViewImplementation
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
