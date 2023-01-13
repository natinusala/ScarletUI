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

struct Text: View {
    @Attribute(\TextTarget.text)
    var text

    typealias Body = Never
    typealias Target = TextTarget

    init(_ text: String) {
        self.text = text
    }
}

class TextTarget: ViewTarget {
    var text: String = ""

    /// Initializer used by ScarletCore.
    public required init(kind: TargetKind, displayName: String) {
        super.init(kind: kind, displayName: displayName)
    }

    /// Initializer used for test assertions.
    init(text: String) {
        self.text = text
        super.init(kind: .view, displayName: "Text")
    }

    override open func equals(to other: ViewTarget) -> Bool {
        guard let other = other as? TextTarget else { return false }
        return self.text == other.text
    }

    override var description: String {
        let children: String
        if self.children.isEmpty {
            children = ""
        } else {
            children = """
            {
                \(self.children.map { "\($0)" }.joined(separator: " "))
            }
            """
        }
        return """
        TextTarget(text: "\(self.text)", \(self.attributes)) \(children)
        """
    }
}
