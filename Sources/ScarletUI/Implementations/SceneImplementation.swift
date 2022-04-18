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
open class SceneImplementation: ImplementationNode, CustomStringConvertible {
    /// Scene display name for debugging purposes.
    let displayName: String

    /// Children of this scene.
    var children: [ViewImplementation] = []

    /// The scene Yoga node.
    let ygNode: YGNodeRef

    /// The node axis.
    /// TODO: test the default value here: ensure a column is actually a column
    @Attribute(defaultValue: Axis.column)
    var axis {
        didSet {
            YGNodeStyleSetFlexDirection(self.ygNode, self.axis.ygFlexDirection)
        }
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

    open func insertChild(_ child: ImplementationNode, at position: Int) {
        guard let child = child as? ViewImplementation else {
            fatalError("Cannot add \(type(of: child)) as child of `SceneImplementation`")
        }

        self.children.insert(child, at: position)
    }

    open func removeChild(at position: Int) {
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
        print("\(indentString)- \(self.description) (\(Self.self))")

        for child in self.children {
            child.printTree(indent: indent + 4)
        }
    }
}

public extension Scene {
    /// Default implementation for user scenes.
    typealias Implementation = SceneImplementation
}
