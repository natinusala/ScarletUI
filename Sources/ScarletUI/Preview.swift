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

// TODO: guard preview under DEBUG everywhere

let previewLogger = Logger(label: "ScarletUI.Preview")

struct DiscoveredPreview: Hashable {
    let type: ObjectIdentifier
    let name: String
    let makeNode: () -> any ElementNode

    init<Previewed: Preview>(from preview: Previewed.Type) {
        self.type = ObjectIdentifier(Previewed.self)
        self.name = String(describing: Previewed.self)

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
}

/// Returns the preview for the given name if found.
func getPreview(named name: String) -> DiscoveredPreview? {
    return discoveredPreviews.first { $0.name == name }
}

// /// App responsible for running a preview.
// struct PreviewApp: App {
//     var previewing: DiscoveredPreview!

//     init() {}

//     var body: some Scene {
//         PreviewWindow(previewing: previewing)
//     }
// }

// /// Window containing the previewed view.
// struct PreviewWindow: Scene {
//     let previewing: DiscoveredPreview

//     var body: some Scene {
//         Window(title: "Preview: \(previewing.name)") {
//             // Content will be inserted by `App.main()`
//         }
//     }
// }
