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

/// Displays text.
public struct Text: View {
    public typealias Body = Never
    public typealias Implementation = TextImplementation

    let text: String

    public init(_ text: String) {
        self.text = text
    }

    public static func updateImplementation(_ implementation: TextImplementation, with view: Text) {
        implementation.text = view.text
    }
}

public class TextImplementation: ViewImplementation {
    var text: String?

    public override var description: String {
        if let text = self.text {
            return "Text(\"\(text)\")"
        }

        return "Text(nil)"
    }
}