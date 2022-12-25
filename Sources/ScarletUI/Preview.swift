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

var discoveredPreviews: Set<DiscoveredPreview> = []

@runtimeMetadata
public struct PreviewDiscovery<Previewed: Preview> {
    public init(attachedTo preview: Previewed.Type) {
        // TODO: is it necessary to check for duplicates?
        let entry = DiscoveredPreview(from: Previewed.self)
        let (inserted, _) = discoveredPreviews.insert(entry)
        if inserted {
            previewLogger.debug("Registered preview: '\(Previewed.self)'")
        }
    }
}

// @PreviewDiscovery
public protocol Preview: View {
    init()

    /// Window mode for the preview.
    ///
    /// If unspecified, the window will try to be as small as possible
    /// to fit its content.
    static var windowMode: WindowMode? { get }

    /// Axis to use when laying out the preview.
    ///
    /// Only useful if there is no top-level row or column in the preview itself
    /// or the previewed content.
    static var axis: Axis { get }
}

public extension Preview {
    static var windowMode: WindowMode? {
        return nil
    }

    static var axis: Axis {
        return defaultAxis
    }
}

/// Returns the preview for the given name if found.
func getPreview(named name: String) -> DiscoveredPreview? {
    return discoveredPreviews.first { $0.name == name }
}

#else

/// Shim version of `Preview` for release configurations where
/// previews are disabled.
public protocol Preview: View {
    init()
}

#endif
