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

/// A desktop window.
public struct Window<Content>: Scene where Content: View {
    public typealias Body = Never
    public typealias Implementation = WindowImplementation

    let title: String
    let content: Content

    public init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    public static func make(scene: Self?, input: MakeInput) -> MakeOutput {
        let contentStorage = input.storage?.edges[0]
        let contentInput = MakeInput(storage: contentStorage)

        return Self.output(
            node: nil,
            staticEdges: [Content.make(view: scene?.content, input: contentInput)],
            implementationProxy: scene?.implementationProxy
        )
    }

    public static func updateImplementation(_ implementation: WindowImplementation, with scene: Self) {
        implementation.title = scene.title
    }
}

public class WindowImplementation: SceneImplementation {
    var title: String?

    public override var description: String {
        if let title = self.title {
            return "Window(\"\(title)\")"
        }

        return "Window()"
    }
}
