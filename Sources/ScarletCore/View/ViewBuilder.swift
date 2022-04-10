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
    /// Builds a block for an empty content. Returns an empty view.
    public static func buildBlock() -> Optional<VoidView> {
        return .none
    }

    /// Builds a block one view. Returns the view itself.
    public static func buildBlock<Content>(_ content: Content) -> Content {
        return content
    }
}

/// A view that has no body or implementation. Used as a type placeholder
/// for the empty builder of `ViewBuilder`. Will never actually be added to the
/// view hierarchy.
public struct VoidView: View {
    public typealias Body = Never
    public typealias Implementation = Never
}
