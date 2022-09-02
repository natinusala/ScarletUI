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

public struct ShrinkModifier: AttributeViewModifier {
    @Attribute(\ViewImplementation.shrink)
    var shrink

    public init(_ shrink: Float) {
        self.shrink = shrink
    }
}

public extension View {
    /// Sets the view shrink factor, aka. the percentage of space the view is allowed to
    /// shrink for if there is not enough space for everyone.
    ///
    /// Opposite of grow.
    func shrink(_ shrink: Float) -> some View {
        self.modifier(ShrinkModifier(shrink))
    }
}
