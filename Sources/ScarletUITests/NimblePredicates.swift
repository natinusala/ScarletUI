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

#if canImport(Nimble)

import Nimble

@testable import ScarletUI

/// Asserts that the given app doesn't have a view with the given tag.
/// Warning: provided Nimble matchers do not run the app (due to lack of async support), so use ``ScarletUIApplication/wait(for:)`` to
/// make sure the app is in the correct state before!
public func notHaveView<Tested>(tagged tag: String) -> Predicate<ScarletUIApplication<Tested>> {
    return Predicate { (actual) throws in
        let msg = ExpectationMessage.expectedTo("not have view tagged '\(tag)'")

        if let app = try actual.evaluate() {
            let found = findView(tagged: tag, in: app.app)
            return PredicateResult(
                bool: found == nil,
                message: msg
            )
        } else {
            return PredicateResult(
                status: .fail,
                message: msg
            )
        }
    }
}

#endif
