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

    @AttributeValue(target: \WindowImplementation.title) var title

    let content: Content

    public init(title: String, @ViewBuilder content: () -> Content) {
        self.content = content()
        self.title = title
    }

    public static func make(scene: Self?, input: MakeInput) -> MakeOutput {
        let contentStorage = input.storage?.edges[0]
        let contentInput = MakeInput(storage: contentStorage)

        return Self.output(
            node: nil,
            staticEdges: [Content.make(view: scene?.content, input: contentInput)],
            implementationAccessor: scene?.implementationAccessor
        )
    }

    public static func updateImplementation(_ implementation: WindowImplementation, with scene: Self) {
        scene.$title.set(on: implementation)
    }
}

public class WindowImplementation: SceneImplementation {
    /// The window title.
    @Attribute var title: String = ""

    public override var description: String {
        return "Window(\"\(title)\")"
    }
}
