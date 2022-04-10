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

// TODO: remove duplication between Column and Row by making a Node view used for both, with an (axis: Axis) parameter

/// A view that arranges its children in a column.
public struct Column<Content>: View where Content: View {
    public typealias Body = Never
    public typealias Implementation = ColumnImplementation

    var content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public static func make(view: Self, input: MakeInput) -> MakeOutput {
        let output = ElementOutput(type: Self.self, storage: nil, implementationProxy: view.implementationProxy)
        let contentStorage = input.storage?.edges[0]

        let contentInput = MakeInput(storage: contentStorage)

        return .changed(new: .init(
            node: output,
            staticEdges: [Content.make(view: view.content, input: contentInput)]
        ))
    }

    public static func staticEdgesCount() -> Int {
        return 1
    }

    public static func updateImplementation(_ implementation: Implementation, with view: Self) {
        // Nothing to update
    }
}

public class ColumnImplementation: ViewImplementation {}
