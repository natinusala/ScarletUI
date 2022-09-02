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
public struct Row<Content>: View where Content: View {
    public typealias Body = Never

    @Attribute(\LayoutImplementationNode.axis, propagate: true)
    var axis

    var content: Content

    public init(reverse: Bool = false, @ViewBuilder content: () -> Content) {
        self.content = content()

        if reverse {
            self.axis = .rowReverse
        } else {
            self.axis = .row
        }
    }

    public static func make(view: Self?, input: MakeInput) -> MakeOutput {
        let contentStorage = input.storage?.edges.staticAt(0, for: Content.self)
        let contentInput = MakeInput(storage: contentStorage, implementationPosition: Self.substantial ? 0 : input.implementationPosition, context: input.context)
        let contentOutput = Content.make(view: view?.content, input: contentInput)

        return Self.output(
            from: input,
            node: ElementOutput(storage: nil, attributes: view?.collectAttributes() ?? [:]),
            staticEdges: [.some(contentOutput)],
            implementationPosition: input.implementationPosition,
            implementationCount: Self.substantial ? 1 : contentOutput.implementationCount,
            accessor: view?.accessor
        )
    }

    public static var edgesType: ElementEdgesType{
        return .static(count: 1)
    }
}
