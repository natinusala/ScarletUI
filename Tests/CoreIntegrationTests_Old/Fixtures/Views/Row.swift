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

import ScarletCore

/// A view that arranges its children in a row.
struct Row<Content>: View where Content: View {
    typealias Body = Never

    var content: Content

    init(@ElementBuilder content: () -> Content) {
        self.content = content()
    }

    static func make(view: Self?, input: MakeInput) -> MakeOutput {
        let contentStorage = input.storage?.edges.staticAt(0, for: Content.self)
        let contentInput = MakeInput(storage: contentStorage, targetPosition: Self.substantial ? 0 : input.targetPosition, context: input.context)
        let contentOutput = Content.make(view: view?.content, input: contentInput)

        return Self.output(
            from: input,
            node: ElementOutput(storage: nil, attributes: view?.collectAttributes() ?? [:]),
            staticEdges: [.some(contentOutput)],
            targetPosition: input.targetPosition,
            targetCount: Self.substantial ? 1 : contentOutput.targetCount,
            accessor: view?.accessor
        )
    }

    static var edgesType: ElementEdgesType{
        return .static(count: 1)
    }
}
