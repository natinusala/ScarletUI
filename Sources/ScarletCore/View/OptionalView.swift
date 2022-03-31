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

extension Optional: View where Wrapped: View {
    public typealias Body = Never

    public static func makeChildren(view: Self) -> ElementChildren {
        switch view {
            case .none:
                return ElementChildren(staticChildren: [nil])
            case let .some(view):
                return ElementChildren(staticChildren: [AnyElement(view: view)])
        }
    }

    public static var staticChildrenCount: Int {
        return 1
    }
}

public extension ViewBuilder {
    /// Builds an optional view.
    static func buildIf<Content: View>(_ content: Content?) -> Content? {
        return content
    }
}
