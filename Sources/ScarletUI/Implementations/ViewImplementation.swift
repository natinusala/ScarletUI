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

/// Implementation for all views.
open class _ViewImplementation: _LayoutImplementationNode, _GamepadButtonEventImplementationNode {
    /// View display name for debugging purposes.
    public let displayName: String

    /// Children of this view.
    var children: [_ViewImplementation] = []

    /// The view Yoga node.
    public let ygNode: YGNodeRef

    /// The computed layout of the view.
    public var layout = Rect() {
        didSet {
            self.fillDirty = true
        }
    }

    /// The parent scene or view implementation.
    var parent: _LayoutImplementationNode?

    /// The view fill, aka. its background color or gradient.
    var fill: Fill = .none {
        didSet {
            self.fillDirty = true
        }
    }

    /// Is the fill paint dirty, aka. does it need to be
    /// recreated at next frame?
    var fillDirty = false

    /// The paint used to draw the view fill.
    var fillPaint: Paint? = nil

    /// Called when a gamepad button is pressed.
    /// The event will be consumed if set.
    var gamepadButtonPressAction = AttributeList<_GamepadButtonPressCallback>()

    /// The view grow factor, aka. the percentage of remaining space to give this view.
    var grow: Float {
        get {
            return YGNodeStyleGetFlexGrow(self.ygNode)
        }
        set {
            YGNodeStyleSetFlexGrow(self.ygNode, newValue)
        }
    }

    /// The view shrink factor, aka. the percentage of space the view is allowed to
    /// shrink for if there is not enough space for everyone.
    var shrink: Float {
        get {
            return YGNodeStyleGetFlexShrink(self.ygNode)
        }
        set {
            YGNodeStyleSetFlexShrink(self.ygNode, newValue)
        }
    }

    /// The node axis.
    public var axis: Axis {
        get {
            return YGNodeStyleGetFlexDirection(self.ygNode).axis
        }
        set {
            YGNodeStyleSetFlexDirection(self.ygNode, newValue.ygFlexDirection)
        }
    }

    /// The view padding, aka. the space between this view and its children.
    var padding: EdgesLayoutValues {
        get {
            return EdgesLayoutValues(
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

    /// The desired width of the view.
    /// Set to `auto` for all views by default.
    ///
    /// The actual width after layout may or may not be the desired width,
    /// however it cannot be less than the desired width.
    var desiredWidth: LayoutValue {
        get {
            return .fromYGValue(YGNodeStyleGetWidth(self.ygNode))
        }
        set {
            switch newValue {
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
        }
    }

    /// The desired height of the view.
    /// Set to `auto` for all views by default.
    ///
    /// The actual height after layout may or may not be the desired height,
    /// however it cannot be less than the desired height.
    var desiredHeight: LayoutValue {
        get {
            return .fromYGValue(YGNodeStyleGetHeight(self.ygNode))
        }
        set {
            switch newValue {
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

    /// The desired size of the view.
    /// Set to `auto` for all views by default.
    ///
    /// The actual size after layout may or may not be the desired size,
    /// however it cannot be less than the desired size.
    var desiredSize: Size {
        get {
            return Size(
                width: self.desiredWidth,
                height: self.desiredHeight
            )
        }
        set {
            self.desiredWidth = newValue.width
            self.desiredHeight = newValue.height
        }
    }

    public required init(displayName: String) {
        self.displayName = displayName

        self.ygNode = YGNodeNew()

        // Set default layout values to make it so that views take
        // all available space by default
        self.desiredSize = Size(width: .auto, height: .auto)

        self.axis = defaultAxis
    }

    deinit {
        YGNodeFree(self.ygNode)
    }

    public func insertChild(_ child: ImplementationNode, at position: Int) {
        guard let child = child as? _ViewImplementation else {
            fatalError("Cannot add \(type(of: child)) as child of `_ViewImplementation`")
        }

        YGNodeInsertChild(self.ygNode, child.ygNode, UInt32(position))
        self.children.insert(child, at: position)

        child.parent = self
    }

    public func removeChild(at position: Int) {
        YGNodeRemoveChild(self.ygNode, self.children[position].ygNode)
        self.children.remove(at: position)
    }

    /// Runs the view for one frame.
    open func frame(canvas: Canvas?) {
        // Run layout
        self.layoutIfNeeded()

        // Rebuild fill paint if needed
        if self.fillDirty {
            self.fillPaint = self.fill.createPaint(inside: self.layout)
            self.fillDirty = false
        }

        // Draw the view
        if let canvas = canvas, self.layout.width > 0 && self.layout.height > 0 {
            self.draw(in: self.layout, canvas: canvas)
        }

        // Draw children
        for child in self.children {
            child.frame(canvas: canvas)
        }
    }

    open func gamepadButtonDidPress(_ button: GamepadButton) -> Bool {
        var consumed = false
        for action in self.gamepadButtonPressAction {
            consumed = consumed || action(button)
        }

        return consumed
    }

    open func gamepadButtonDidRelease(_ button: GamepadButton) -> Bool {
        // Nothing by default
        return false
    }

    /// Draws the view on screen.
    open func draw(in bounds: Rect, canvas: Canvas) {
        // Draw fill
        if let fillPaint = self.fillPaint {
            canvas.drawRect(bounds, paint: fillPaint)
        }
    }

    open func attributesDidSet() {
        // Nothing by default
    }

    public func printTree(indent: Int = 0) {
        let indentString = String(repeating: " ", count: indent)
        print("\(indentString)- \(self.description) (\(Self.self)) - axis: \(self.axis)")

        for child in self.children {
            child.printTree(indent: indent + 4)
        }
    }

    public var layoutParent: _LayoutImplementationNode? {
        return self.parent
    }

    public var layoutChildren: [_LayoutImplementationNode] {
        return self.children.map { $0 as _LayoutImplementationNode }
    }
}

public extension View {
    /// Default implementation for user views.
    typealias Implementation = _ViewImplementation
}
