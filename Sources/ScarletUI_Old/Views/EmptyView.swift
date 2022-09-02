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

/// A view with no body.
///
/// As this view does not have any content, it does not have
/// any width or height in the container view or scene axis.
/// Consequently, you have to use layout modifiers
/// such as `grow`, `width` or `height` to give it the desired size.
public struct EmptyView: View {
    public typealias Body = Never
}
