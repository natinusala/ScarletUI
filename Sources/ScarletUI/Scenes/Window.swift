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

    @AttributeValue(\WindowImplementation.title) var title
    @AttributeValue(\WindowImplementation.mode) var mode
    @AttributeValue(\WindowImplementation.backend) var backend

    let content: Content

    public init(
        title: String,
        mode: WindowMode = .getDefault(),
        backend: GraphicsBackend = .getDefault(),
        @ViewBuilder content: () -> Content
    ) {
        self.content = content()
        self.title = title
        self.mode = mode
        self.backend = backend
    }

    public static func make(scene: Self?, input: MakeInput) -> MakeOutput {
        let contentStorage = input.storage?.edges[0]
        let contentInput = MakeInput(storage: contentStorage)

        return Self.output(
            node: nil,
            staticEdges: [Content.make(view: scene?.content, input: contentInput)],
            accessor: scene?.accessor
        )
    }
}

public class WindowImplementation: SceneImplementation {
    /// The window title.
    @Attribute var title = ""

    /// The window mode.
    @Attribute var mode: WindowMode = .getDefault()

    /// The window graphics backend.
    @Attribute var backend: GraphicsBackend = .getDefault()

    /// The native window handle.
    var handle: NativeWindow?

    public override func onAttributesReady() {
        do {
            // Create the native window
            let handle = try Context.shared.platform.createWindow(
                title: self.title,
                mode: self.mode,
                backend: self.backend
            )
            self.handle = handle

            Logger.info("Created a \(self.mode.name) \(self.backend.name) window (\(handle.size.width)x\(handle.size.height))")

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
            YGNodeStyleSetWidth(self.ygNode, handle.size.width)
            YGNodeStyleSetMinWidth(self.ygNode, handle.size.width)
            YGNodeStyleSetHeight(self.ygNode, handle.size.height)
            YGNodeStyleSetMinHeight(self.ygNode, handle.size.height)
        }
    }

    public override var description: String {
        return "Window(title: \"\(self.title)\", mode: \(self.mode))"
    }
}
