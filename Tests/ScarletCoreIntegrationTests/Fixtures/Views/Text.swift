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

struct Text: StatelessLeafView {
    @Attribute(\TextImpl.text)
    var text

    typealias Body = Never
    typealias Implementation = TextImpl

    init(_ text: String) {
        self.text = text
    }
}

class TextImpl: ViewImpl {
    var text: String = ""
    var textColor = Color.black {
        didSet {
            textColorChanged = true
        }
    }

    var textColorChanged = false

    /// Initializer used by ScarletCore.
    public required init(displayName: String) {
        super.init(displayName: displayName)
    }

    /// Initializer used for test assertions.
    init(text: String, textColor: Color = .black) {
        self.text = text
        self.textColor = textColor
        super.init(displayName: "Text")
    }

    override func reset() {
        super.reset()

        self.textColorChanged = false
    }

    override open func equals(to other: ViewImpl) -> Bool {
        guard let other = other as? TextImpl else { return false }
        return self.text == other.text && self.textColor == other.textColor
    }

    override var customAttributesDebugDescription: String {
        return "text=\"\(self.text)\" textColor=\"\(self.textColor)\""
    }
}
