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

/// A view that is either the first content or the second content.
public enum ConditionalView<FirstContent, SecondContent>: View where FirstContent: View, SecondContent: View {
    case first(FirstContent)
    case second(SecondContent)

    public typealias Body = Never

    public static func makeChildren(view: Self) -> ElementChildren {
        switch view {
            case let .first(firstContent):
                return ElementChildren(staticChildren: [AnyElement(view: firstContent)])
            case let .second(secondContent):
                return ElementChildren(staticChildren: [AnyElement(view: secondContent)])
        }
    }

    public static var staticChildrenCount: Int {
        return 1
    }
}

public extension ViewBuilder {
    static func buildEither<FirstContent, SecondContent>(first: FirstContent) -> ConditionalView<FirstContent, SecondContent> {
        return .first(first)
    }

    static func buildEither<FirstContent, SecondContent>(second: SecondContent) -> ConditionalView<FirstContent, SecondContent> {
        return .second(second)
    }
}
