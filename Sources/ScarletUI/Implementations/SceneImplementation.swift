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

/// Implementation for all scenes.
open class _SceneImplementation: ImplementationNode, _LayoutImplementationNode, _GamepadButtonEventImplementationNode, _TagImplementationNode {
    public let displayName: String

    /// Children of this scene.
    var children: [_ViewImplementation] = []

    /// The scene Yoga node.
    public let ygNode: YGNodeRef

    /// The computed layout of the scene.
    public var layout = Rect()

    /// The parent app implementation.
    weak var parent: _AppImplementation?

    /// The gamepad state of the previous frame.
    var previousGamepadState = _GamepadState.neutral

    // Current platform. Available once `create(platform:)` is called.
    var platform: _Platform?

    public var tag: String?

    public var layoutParent: _LayoutImplementationNode? {
        return self.parent as? _LayoutImplementationNode
    }

    public var layoutChildren: [_LayoutImplementationNode] {
        return self.children.map { $0 as _LayoutImplementationNode }
    }

    public var tagChildren: [any _TagImplementationNode] {
        return self.children.map { $0 as any _TagImplementationNode }
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

    /// The desired size of the scene.
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

    public required init(displayName: String) {
        self.displayName = displayName

        self.ygNode = YGNodeNew()
        YGNodeStyleSetFlexDirection(self.ygNode, YGFlexDirectionColumn)
    }

    /// Runs the scene for one frame.
    /// Returns `true` if the scene should exit.
    open func frame() -> Bool {
        return false
    }

    /// Called by the parent app when the scene is ready to be created.
    /// This should be the time to initialize any native resources such as windows or graphics context.
    open func create(platform: _Platform) {
        self.platform = platform
    }

    /// Polls and updates input state.
    func updateInputs() {
        // Poll inputs
        var state = self.pollGamepad().process(previous: self.previousGamepadState)

        assert(
            state.physicalButtons.count == PhysicalGamepadButton.allCases.count,
            "Physical gamepad button count mismatch - returned \(state.physicalButtons.count) but expected \(PhysicalGamepadButton.allCases.count)"
        )

        assert(
            state.virtualButtons.count == VirtualGamepadButton.allCases.count,
            "Virtual gamepad button count mismatch - returned \(state.virtualButtons.count) but expected \(VirtualGamepadButton.allCases.count)"
        )

        // Compare state with previous frame
        let allButtons = PhysicalGamepadButton.allCases.map({ $0.toGamepadButton() }) + VirtualGamepadButton.allCases.map({ $0.toGamepadButton() })

        for (idx, button) in allButtons {
            let new: _ButtonState
            let previous: _ButtonState
            switch button {
                case .physical:
                    new = state.physicalButtons[idx]
                    previous = self.previousGamepadState.physicalButtons[idx]
                case .virtual:
                    new = state.virtualButtons[idx]
                    previous = self.previousGamepadState.virtualButtons[idx]
            }

            switch (previous, new) {
                case (.released, .pressed):
                    self.pressGamepadButton(button)
                case (.pressed, .pressed(_, let consumed)):
                    if !consumed && new.isLongPress {
                        state.consume(button, at: idx)
                        self.longPressGamepadButton(button)
                    }
                case (.pressed, .released):
                    self.releaseGamepadButton(button)
                default:
                    break
            }
        }

        self.previousGamepadState = state
    }

    open func gamepadButtonDidPress(_ button: GamepadButton) -> Bool {
        // Nothing by default
        return false
    }

    open func gamepadButtonDidRelease(_ button: GamepadButton) -> Bool {
        // Nothing by default
        return false
    }

    open func gamepadButtonDidLongPress(_ button: GamepadButton) -> Bool {
#if DEBUG
        if case .physical(.debug) = button {
            // Handle debug button
            guard let platform else {
                appLogger.error("Cannot open Yoga Playground: platform is not set in scene '\(self.displayName)', was `super.create(platform:)` called?")
                return true
            }

            openYogaPlayground(for: self, platform: platform)
            return true
        }
#endif

        return false
    }

    /// Called every frame to poll inputs. Must be overridden by subclasses.
    open func pollGamepad() -> _PhysicalGamepadState {
        fatalError("Scene \(self) does not override` pollGamepad()`")
    }

    public func attributesDidSet() {

    }

    open func insertChild(_ child: ImplementationNode, at position: Int) {
        guard let child = child as? _ViewImplementation else {
            fatalError("Cannot add \(type(of: child)) as child of '_SceneImplementation'")
        }

        YGNodeInsertChild(self.ygNode, child.ygNode, UInt32(position))
        self.children.insert(child, at: position)

        child.parent = self
    }

    open func removeChild(at position: Int) {
        YGNodeRemoveChild(self.ygNode, self.children[position].ygNode)
        self.children.remove(at: position)
    }

    deinit {
        YGNodeFree(self.ygNode)
    }
}

public extension Scene {
    /// Default implementation type for scenes.
    typealias Implementation = _SceneImplementation
}
