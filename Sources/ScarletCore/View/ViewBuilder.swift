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

/// Result builder for a view's body.
@resultBuilder
public struct ViewBuilder {
    /// Builds a block for an empty view. Returns an empty view.
    public static func buildBlock() -> EmptyView? {
        return EmptyView?.none
    }

    /// Builds a block for an optional view. Can return the optional view directly thanks
    /// to the `Optional` extension.
    public static func buildIf<Content: View>(_ content: Content?) -> Content? {
        return content
    }

    /// Builds a block for a single view.
    public static func buildBlock<Content: View>(_ content: Content) -> Content {
        return content
    }

    /// Builds a block for a conditional view with first content.
    public static func buildEither<FirstContent, SecondContent>(first: FirstContent) -> ConditionalView<FirstContent, SecondContent> {
        return .first(first)
    }

    /// Builds a block for a conditional view.
    public static func buildEither<FirstContent, SecondContent>(second: SecondContent) -> ConditionalView<FirstContent, SecondContent> {
        return .second(second)
    }
}
