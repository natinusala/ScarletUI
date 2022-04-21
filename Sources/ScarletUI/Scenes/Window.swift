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

/// A desktop window.
/// Views are arranged in a column by default.
public struct Window<Content>: Scene where Content: View {
    public typealias Body = Never
    public typealias Implementation = WindowImplementation

    @Attribute(\WindowImplementation.title)
    var title

    @Attribute(\WindowImplementation.mode)
    var mode

    @Attribute(\WindowImplementation.backend)
    var backend

    @Attribute(\LayoutImplementationNode.axis, propagate: true)
    var axis

    let content: Content

    public init(
        title: String? = nil,
        mode: WindowMode? = nil,
        backend: GraphicsBackend? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.content = content()

        self.$title.setFromOptional(value: title)
        self.$mode.setFromOptional(value: mode)
        self.$backend.setFromOptional(value: backend)

        self.axis = .column
    }

    public static func make(scene: Self?, input: MakeInput) -> MakeOutput {
        let contentStorage = input.storage?.edges[0]
        let contentInput = MakeInput(storage: contentStorage)

        return Self.output(
            node: ElementOutput(storage: nil, attributes: scene?.collectAttributes() ?? [:]),
            staticEdges: [Content.make(view: scene?.content, input: contentInput)],
            accessor: scene?.accessor
        )
    }
}

public class WindowImplementation: SceneImplementation {
    /// The window title.
    var title = ""

    /// The window mode.
    var mode = WindowMode.getDefault()

    /// The window graphics backend.
    var backend = GraphicsBackend.getDefault()

    /// The native window handle.
    var handle: NativeWindow?

    public override func attributesDidSet() {
        super.attributesDidSet()

        do {
            // Create the native window
            let handle = try Context.shared.platform.createWindow(
                title: self.title,
                mode: self.mode,
                backend: self.backend
            )
            self.handle = handle

            Logger.info("Created a \(self.mode.name) \(self.backend.name) window (title: \"\(self.title)\", size: \(handle.size.width)x\(handle.size.height))")

            // Set the initial node dimensions
            self.onResize()
        } catch {
            Logger.error("Unable to create window: \(error)")
            exit(-1)
        }
    }

    /// Called after the window gets resized by the user.
    func onResize() {
        if let handle = self.handle {
            self.desiredSize = Size(width: handle.size.width.dip, height: handle.size.height.dip)
        }
    }

    public override var description: String {
        return "Window(title: \"\(self.title)\", mode: \(self.mode))"
    }
}
