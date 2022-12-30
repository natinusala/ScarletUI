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

import Foundation
import XCTest

@testable import ScarletUI

func findView(tagged tag: String, in node: _TagImplementationNode) -> _ViewImplementation? {
    func inner(node: _TagImplementationNode) -> _ViewImplementation? {
        print("Trying node \(node.displayName) tagged \(node.tag)")
        if let view = node as? _ViewImplementation, view.tag == tag {
            return view
        } else {
            for child in node.tagChildren {
                if let found = inner(node: child) {
                    return found
                }
            }
        }

        return nil
    }

    return inner(node: node)
}
