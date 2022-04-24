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

/// Implementation for all scenes.
open class SceneImplementation: LayoutImplementationNode, CustomStringConvertible {
    /// Scene display name for debugging purposes.
    let displayName: String

    /// Children of this scene.
    var children: [ViewImplementation] = []

    /// The scene Yoga node.
    public let ygNode: YGNodeRef

    /// The computed layout of the scene.
    public var layout = Rect()

    /// The parent app implementation.
    var parent: AppImplementation?

    public var layoutParent: LayoutImplementationNode? {
        return self.parent as? LayoutImplementationNode
    }

    public var layoutChildren: [LayoutImplementationNode] {
        return self.children.map { $0 as LayoutImplementationNode }
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

    /// Runs the scene for one frame.
    /// Returns `true` if the scene should exit.
    open func frame() -> Bool {
        return false
    }

    public required init(kind: ImplementationKind, displayName: String) {
        guard kind == .scene else {
            fatalError("Tried to create a `ViewImplementation` with kind \(kind)")
        }

        self.displayName = displayName

        self.ygNode = YGNodeNew()
        YGNodeStyleSetFlexDirection(self.ygNode, YGFlexDirectionColumn)
    }

    deinit {
        YGNodeFree(self.ygNode)
    }

    /// Called by the parent app when the scene is ready to be created.
    /// This should be the time to initialize any native resources such as windows or graphics context.
    open func create(platform: Platform) {
        // Nothing by default
    }

    open func insertChild(_ child: ImplementationNode, at position: Int) {
        guard let child = child as? ViewImplementation else {
            fatalError("Cannot add \(type(of: child)) as child of `SceneImplementation`")
        }

        YGNodeInsertChild(self.ygNode, child.ygNode, UInt32(position))
        self.children.insert(child, at: position)

        child.parent = self
    }

    open func removeChild(at position: Int) {
        YGNodeRemoveChild(self.ygNode, self.children[position].ygNode)
        self.children.remove(at: position)
    }

    open func attributesDidSet() {
        // Nothing by default
    }

    public var description: String {
        return self.displayName
    }

    public func printTree(indent: Int = 0) {
        let indentString = String(repeating: " ", count: indent)
        print("\(indentString)- \(self.description) (\(Self.self)) - axis: \(self.axis)")

        for child in self.children {
            child.printTree(indent: indent + 4)
        }
    }
}

public extension Scene {
    /// Default implementation for user scenes.
    typealias Implementation = SceneImplementation
}
