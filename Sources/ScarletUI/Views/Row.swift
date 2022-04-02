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

    var content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public static func makeChildren(view: Self) -> ChildrenOutput {
        return ChildrenOutput(staticChildren: [AnyElement(view: view.content)])
    }

    public static var staticChildrenCount: Int {
        return 1
    }
}
