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

struct Image: LeafView {
    @Attribute(\ImageImpl.source)
    var source

    typealias Body = Never
    typealias Implementation = ImageImpl

    init(source: String) {
        self.source = source
    }
}

class ImageImpl: ViewImpl {
    var source: String = ""

    /// Initializer used by ScarletCore.
    public required init(displayName: String) {
        super.init(displayName: displayName)
    }

    /// Initializer used for test assertions.
    init(source: String) {
        self.source = source
        super.init(displayName: "Image")
    }

    override open func equals(to other: ViewImpl) -> Bool {
        guard let other = other as? ImageImpl else { return false }
        return self.source == other.source
    }

    override var customAttributesDebugDescription: String {
        return "source=\"\(self.source)\""
    }
}