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

import Logging
import Foundation

let previewLogger = Logger(label: "ScarletUI.Preview")

#if DEBUG

struct DiscoveredPreview: Hashable {
    let type: ObjectIdentifier
    let name: String
    let windowMode: WindowMode?
    let axis: Axis
    let makeNode: () -> any ElementNode

    init<Previewed: Preview>(from preview: Previewed.Type) {
        self.type = ObjectIdentifier(Previewed.self)
        self.name = String(describing: Previewed.self)
        self.windowMode = Previewed.windowMode
        self.axis = Previewed.axis

        self.makeNode = {
            return Previewed.makeNode(of: Previewed(), in: nil, implementationPosition: 0, using: .root())
        }
    }

    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.type == rhs.type
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(self.type)
    }
}

private var discoveredPreviews: Set<DiscoveredPreview> = []

/// Registers a preview.
/// TODO: remove manual discovery and use @runtimeAttribute to make automated discovery once https://forums.swift.org/t/pitch-custom-metadata-attributes/62016 is available (debug only too)
public func registerPreview<T: Preview>(_ preview: T.Type) {
    discoveredPreviews.insert(DiscoveredPreview(from: T.self))
}

/// Returns discovered previews.
func getDiscoveredPreviews() -> Set<DiscoveredPreview> {
    return discoveredPreviews
}

/// Allows running the app in "preview mode", displaying a smaller window with only the
/// preview content inside.
/// Use by giving `--preview` with the preview name.
/// Only available in debug configuration.
public protocol Preview: View {
    init()

    /// Window mode for the preview.
    ///
    /// If unspecified, the window will try to be as small as possible
    /// to fit its content.
    static var windowMode: WindowMode? { get }
}

public extension Preview {
    static var windowMode: WindowMode? {
        return nil
    }

    static var axis: Axis {
        return .default
    }
}

/// Returns the preview for the given name if found.
func getPreview(named name: String) -> DiscoveredPreview? {
    return discoveredPreviews.first { $0.name == name }
}

public extension App {
    /// Parses arguments and runs the app in preview mode if requested.
    /// Will return `true` if the preview was executed.
    static func runForPreviewIfNeeded(arguments: Arguments) -> Bool {
        /// List previews if requested
        if arguments.listPreviews {
            getDiscoveredPreviews().forEach {
                print($0.name)
            }
            return true
        }

        // If running in preview mode, wrap the preview view in a premade made app and window
        // The preview becomes the top-level node instead of the app
        if let previewing = arguments.preview {
            // Try to find the view to preview
            guard let preview = getPreview(named: previewing) else {
                appLogger.error("Did not find preview named '\(previewing)', does it conform to 'Preview'?")
                if getDiscoveredPreviews().isEmpty {
                    appLogger.error("No previews are currently available")
                } else {
                    appLogger.error("Available previews: \(getDiscoveredPreviews().map { $0.name }.joined(separator: ", "))")
                }

                exit(-1)
            }

            // Make an app and window node
            let app = _AppImplementation(displayName: "PreviewApp")
            let window = _WindowImplementation(displayName: "PreviewWindow")
            window.title = "Preview \(preview.name)"

            // Make the preview node and insert it in the window
            let root = preview.makeNode()

            guard let implementation = root.implementation as? _ViewImplementation else {
                fatalError("No implementation found for preview node or got implementation of the wrong type")
            }

            implementation.grow = 1.0 // make the view take the whole window

            // Setup window size: use provided mode or layout the preview and fit the window
            if let windowMode = preview.windowMode {
                window.mode = windowMode
            } else {
                implementation.layoutIfNeeded()

                if implementation.layout.width == 0 || implementation.layout.height == 0 {
                    appLogger.error("Cannot create a window for a preview with no width or height.")
                    appLogger.error("Please set a window size by adding a 'windowMode' property to '\(preview.name)'.")
                    exit(-1)
                }

                appLogger.debug("Calculated preview size: \(implementation.layout)")

                window.mode = .windowed(width: implementation.layout.width, height: implementation.layout.height)
            }

            // Glue everything together
            window.insertChild(implementation, at: 0)
            app.insertChild(window, at: 0)

            // Load previous window position once the window is created and run the app until exit
            Self.loadPreviewPosition(in: window)
            app.run()

            // Try to get and save the window position to store it for next time
            // TODO: add a --reset-preview-position option to prevent softlocks
            Self.savePreviewPosition(of: window)

            return true
        }

        return false
    }

    /// Saves preview position to a temporary directory.
    /// Format is `{x}\n{y}`.
    /// See ``previewPositionTempPath`` for file location.
    static func savePreviewPosition(of window: _WindowImplementation) {
        if let windowPosition = window.handle?.position {
            try? "\(windowPosition.x)\n\(windowPosition.y)".write(to: Self.previewPositionTempPath, atomically: false, encoding: .utf8)
            appLogger.debug("Window position \(windowPosition) saved to \(Self.previewPositionTempPath)")
        }
    }

    /// Attempts to load preview position from temporary file.
    /// See ``savePreviewPosition`` for format and location.
    static func loadPreviewPosition(in window: _WindowImplementation) {
        guard let content = try? String(contentsOf: Self.previewPositionTempPath) else {
            appLogger.debug("Cannot load last preview position: I/O error")
            return
        }

        let split = content.split(separator: "\n")

        guard split.count == 2 else {
            appLogger.debug("Cannot load last preview position: bad format")
            return
        }

        guard let x = Int(split[0]), let y = Int(split[1]) else {
            appLogger.debug("Cannot load last preview position: bad format")
            return
        }

        guard var handle = window.handle else {
            appLogger.debug("Cannot load last preview position: native handle not available")
            return
        }

        handle.position = (x: x, y: y)
        appLogger.debug("Preview window position set to \((x: x, y: y))")
    }

    static var previewPositionTempPath: URL {
        return FileManager.default.temporaryDirectory / "\(Self.self)_PreviewPosition"
    }
}

#else

/// Shim version of `Preview` for release configurations where
/// previews are disabled.
public protocol Preview: View {
    init()
}

/// Shim version of `registerPreview(_:)` for release configurations where
/// previews are disabled.
public func registerPreview<T: Preview>(_ preview: T.Type) {}

#endif
