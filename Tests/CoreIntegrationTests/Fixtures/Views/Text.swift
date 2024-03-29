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
import Foundation

struct Text: StatelessLeafView {
    @Attribute(\TextTarget.text)
    var text

    typealias Body = Never
    typealias Target = TextTarget

    init(_ text: String) {
        self.text = text
    }
}

enum TextDecoration {
    case italic
    case underlined
    case strikethrough
    case bold
    case uppercased
}

class TextTarget: ViewTarget {
    var text: String = ""
    var textColor = Color.black {
        didSet {
            textColorChanged = true
        }
    }

    var decorations = AttributeList<TextDecoration>() {
        didSet {
            decorationsChanged = true
        }
    }

    var textColorChanged = false
    var decorationsChanged = false

    /// Initializer used by ScarletCore.
    public required init(displayName: String) {
        super.init(displayName: displayName)
    }

    /// Initializer used for test assertions.
    convenience init(text: String, textColor: Color = .black, decorations: [TextDecoration] = [], tags: [String] = []) {
        self.init("Text", tags: tags)

        self.text = text
        self.textColor = textColor
        self.decorations = .init(uniqueKeysWithValues: decorations.map { (UUID(), $0) })
    }

    override func reset() {
        super.reset()

        self.textColorChanged = false
        self.decorationsChanged = false
    }

    override open func equals(to other: ViewTarget) -> Bool {
        guard let other = other as? TextTarget else { return false }
        return self.text == other.text && self.textColor == other.textColor && self.decorations == other.decorations
    }

    override var customAttributesDebugDescription: String {
        return "text=\"\(self.text)\" textColor=\"\(self.textColor)\" decorations=\"\(self.decorations)\""
    }
}
