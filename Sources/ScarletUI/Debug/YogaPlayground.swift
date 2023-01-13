/*
   Copyright 2023 natinusala

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

#if DEBUG

import Foundation

// TODO: fix release config

/// Yoga Playground URL.
private let playgroundUrl = "https://yogalayout.com/playground/"

protocol PlaygroundNodeConvertible {
    var desiredHeight: LayoutValue { get }
    var desiredWidth: LayoutValue { get }
    var grow: Float { get }
    var shrink: Float { get }
    var axis: Axis { get }
    var padding: EdgesLayoutValues { get }

    var playgroundNodeConvertibleChildren: [any PlaygroundNodeConvertible] { get }
}

/// A layout node that the online Yoga Playground app can parse and display.
/// Mirror of https://github.com/facebook/yoga/blob/main/website/src/components/Playground/src/LayoutRecord.js
struct PlaygroundNode: Encodable {
    let width: LayoutValue
    let height: LayoutValue
    let flexGrow: LayoutValue
    let flexShrink: LayoutValue
    let flexDirection: Axis
    let padding: EdgesLayoutValues

    let children: [PlaygroundNode]

    init(from node: PlaygroundNodeConvertible) {
        self.width = node.desiredWidth
        self.height = node.desiredHeight
        self.flexGrow = .dip(value: node.grow)
        self.flexShrink = .dip(value: node.shrink)
        self.flexDirection = node.axis
        self.padding = node.padding

        self.children = node.playgroundNodeConvertibleChildren.map { PlaygroundNode(from: $0) }
    }
}

extension EdgesLayoutValues: Encodable {
    enum CodingKeys: CodingKey {
        case top
        case right
        case bottom
        case left
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.top, forKey: .top)
        try container.encode(self.right, forKey: .right)
        try container.encode(self.bottom, forKey: .bottom)
        try container.encode(self.left, forKey: .left)
    }
}

extension Axis: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.ygFlexDirection.rawValue)
    }
}

extension LayoutValue: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()

        switch self {
            case .auto:
                try container.encode("auto")
            case .dip(value: let value):
                try container.encode(String(format: "%.1f", value))
            case .percentage(let value):
                try container.encode(String(format: "%.1f%%", value))
            case .undefined:
                try container.encodeNil()
        }
    }
}

extension _WindowTarget: PlaygroundNodeConvertible {
    var padding: EdgesLayoutValues {
        return .undefined()
    }

    var desiredWidth: LayoutValue {
        guard let width = self.handle?.size.width else {
            appLogger.error("Cannot window width, using default")
            return .dip(value: defaultWindowWidth)
        }

        return .dip(value: width)
    }

    var desiredHeight: LayoutValue {
        guard let height = self.handle?.size.height else {
            appLogger.error("Cannot get window height, using default")
            return .dip(value: defaultWindowHeight)
        }

        return .dip(value: height)
    }

    var grow: Float {
        return 1.0
    }

    var shrink: Float {
        return 0.0
    }

    var playgroundNodeConvertibleChildren: [PlaygroundNodeConvertible] {
        return self.children
    }
}

extension _ViewTarget: PlaygroundNodeConvertible {
    var playgroundNodeConvertibleChildren: [PlaygroundNodeConvertible] {
        return self.children
    }
}

/// Opens the Yoga Playground web page with the given node as root.
func openYogaPlayground(for node: TargetNode, platform: any _Platform) {
    guard let convertible = node as? PlaygroundNodeConvertible else {
        appLogger.error("'\(type(of: node))' cannot be serialized for Yoga Playground as it doesn't conform to 'PlaygroundNodeConvertible'")
        return
    }

    let root = PlaygroundNode(from: convertible)

    let encoder = JSONEncoder()

    do {
        encoder.outputFormatting = .prettyPrinted

        let data = try encoder.encode(root)
        let base64 = data.base64EncodedString()
        let url = "\(playgroundUrl)?\(base64)"

        if let json = String(data: data, encoding: .utf8) {
            appLogger.debug("Opening Yoga Playground with config: \(json)")
        }

        try platform.openBrowser(for: url)
    } catch {
        appLogger.error("'\(type(of: node))' could not be serialized for Yoga Playground: \(error)")
    }
}

#else

#endif
