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

/// A type that collects multiple instances of a content type — like views, scenes, or commands — into a single unit.
public struct Group<Content> {
    let content: Content
}

extension Group: View where Content: View {
    public typealias Body = Never

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public static func make(view: Self?, input: MakeInput) -> MakeOutput {
        let output = ElementOutput(storage: nil)
        let contentStorage = input.storage?.edges[0]

        let contentInput = MakeInput(storage: contentStorage)

        return Self.output(
            node: output,
            staticEdges: [Content.make(view: view?.content, input: contentInput)]
        )
    }

    public static func staticEdgesCount() -> Int {
        return 1
    }
}

// TODO: Make an extension of `ModifiedContent` where `Content == Group` to change how modifiers are applied to groups once implementations are finished
// The SwiftUI documentation states "The modifier applies to all members of the group — and not to the group itself.", so we need a criteria to
// determine what a "member" is, and the presence of an implementation is a good candidate (Text is a member, Sidebar is a member, Optional is not)
