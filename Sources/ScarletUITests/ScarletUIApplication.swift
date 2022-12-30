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

/// Default timeout when awaiting for elements and interactions of the app, in seconds.
public let defaultTimeout = 5

/// A tested ScarletUI application runner. Can be bound to an app, a scene or a view.
@MainActor
public class ScarletUIApplication<Tested: Element> {
    let app: _AppImplementation

    /// Creates a new runner for a view.
    /// The view is inserted with grow at 1.0 in a window which size if specified by the `windowMode` parameter.
    /// TODO: add a headless mode
    @MainActor
    public init(
        testing view: Tested,
        windowMode: WindowMode
    ) where Tested: View {
        let app = _AppImplementation(displayName: "ScarletUITests")
        let window = _WindowImplementation(displayName: "ScarletUITests Window")
        window.title = "ScarletUITests Window"
        window.mode = windowMode

        let root = Tested.makeNode(of: view, in: nil, implementationPosition: 0, using: .root())

        guard let implementation = root.implementation as? _ViewImplementation else {
            fatalError("No implementation found for tested node or got implementation of the wrong type")
        }

        implementation.grow = 1.0 // make the view take the whole window

        window.insertChild(implementation, at: 0)
        app.insertChild(window, at: 0)

        self.app = app
    }

    /// Waits for the view with the given tag to appear in the tree and returns its handle if found.
    /// Otherwise raises an assertion error to fail the test.
    /// Timeout is in seconds.
    @MainActor
    public func view(tagged tag: String, timeout: Int = defaultTimeout) async -> _ViewImplementation? {
        var view: _ViewImplementation? = nil

        await self.runUntil(timeout: timeout) {
            if let foundView = findView(tagged: tag, in: self.app) {
                view = foundView
                return true
            }

            return false
        }

        if view == nil {
            XCTFail("Did not find view tagged '\(tag)' in \(timeout) seconds")
        }

        return view
    }

    /// Runs the app until the given condition is met or until the timeout expires (in seconds).
    /// Returns `true` if the condition was ever met, `false` if the timeout expired.
    @discardableResult
    @MainActor
    private func runUntil(timeout: Int, condition: () async -> Bool) async -> Bool {
        let deadline = Date().addingTimeInterval(Double(timeout))

        while Date() <= deadline {
            _ = self.app.frame()

            if await condition() {
                return true
            }
        }

        return false
    }
}
