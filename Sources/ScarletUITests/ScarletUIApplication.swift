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
import Needler

@testable import ScarletUI

// TODO: finish layout UI tests - rename Implementation to Target - make TargetContext - make performancemode - make Shared @Singleton - test libretro runner

/// Default timeout when awaiting for elements and interactions of the app, in seconds.
public let defaultTimeout = 5

/// A tested ScarletUI application runner. Can be bound to an app, a scene or a view.
@MainActor
public class ScarletUIApplication<Tested: Element> where Tested.Node: StatefulElementNode {
    let app: _AppImplementation
    let root: Tested.Node

    /// Creates a new runner for a view.
    /// The view is inserted with grow at 1.0 in a window which size is
    /// specified by the `windowMode` parameter.
    /// Note: headless only works with fixed size windowed mode.
    @MainActor
    public init(
        testing view: Tested,
        windowMode: WindowMode,
        headless: Bool = true
    ) where Tested: View {
        if headless {
            DefaultPlatformResolver.shared = HeadlessPlatformResolver()
        } else {
            DefaultPlatformResolver.resetInjection()
        }

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
        self.root = root
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

    /// Finds a state property in the tested element and sets it to the given value.
    @MainActor
    public func setState<Value>(_ name: String, to value: Value) async {
        do {
            let result = try ScarletUITests.setState(named: name, to: value, on: self.root)

            if result {
                // Run the app for a few frames to make sure everything is updated (including layout, which is lazy)
                // Since state uses Combine internally, main queue needs to be drained a bit
                await self.run(for: 5)
            } else {
                XCTFail("State property '\(name)' not found in struct '\(Tested.self)'")
            }
        } catch {
            XCTFail("Failed to set state property '\(name)' in '\(Tested.self)': \(error)")
        }
    }

    /// Runs the app for the given amount of time without doing anything.
    @MainActor
    public func wait(for timeout: Int) async {
        await self.runUntil(timeout: timeout) {
            return false
        }
    }

    /// Runs the app for the given amount of frames.
    @MainActor
    public func run(for frames: Int) async {
        for _ in (0..<frames) {
            _ = self.app.frame()

            // XCTest owns the run loop so yield to give it time
            // to process the rest of the tasks
            await Task.yield()
        }
    }

    /// Updates the tested element with a new version.
    @MainActor
    public func update(with tested: Tested) async {
        _ = self.root.update(with: tested, implementationPosition: 0, using: root.context)

        // Run the app for a few frames to update layout
        await self.run(for: 5)
    }

    /// Runs the app until the given condition is met or until the timeout expires (in seconds).
    /// Returns `true` if the condition was ever met, `false` if the timeout expired.
    @discardableResult
    @MainActor
    private func runUntil(timeout: Int, condition: () async -> Bool) async -> Bool {
        let deadline = Date().addingTimeInterval(Double(timeout))

        while Date() <= deadline {
            _ = self.app.frame()
            await Task.yield()

            if await condition() {
                return true
            }
        }

        return false
    }
}

struct HeadlessPlatformResolver: PlatformResolver {
    func createPlatform() throws -> _Platform? {
        return HeadlessPlatform()
    }
}

struct HeadlessPlatform: _Platform {
    let name = "Headless"

    func pollEvents() {}

    func createWindow(title: String, mode: ScarletUI.WindowMode, backend: ScarletUI.GraphicsBackend, srgb: Bool) throws -> _NativeWindow {
        guard case .windowed(let width, let height) = mode else {
            fatalError("Headless tests can only be used with windowed mode")
        }

        return HeadlessWindow(size: (width: width, height: height), context: HeadlessContext())
    }
}

struct HeadlessWindow: _NativeWindow {
    var shouldClose = false
    var position: (x: Int, y: Int)? = (x: 0, y: 0)

    var size: WindowSize
    var context: _GraphicsContext

    init(size: WindowSize, context: _GraphicsContext) {
        self.size = size
        self.context = context
    }

    func swapBuffers() {}

    func pollGamepad() -> ScarletUI._GamepadState {
        return .neutral
    }
}

struct HeadlessContext: _GraphicsContext {
    let canvas: any Canvas = HeadlessCanvas()
}

struct HeadlessCanvas: Canvas {
    func drawPaint(_ paint: ScarletUI.Paint) {}
    func drawRect(_ rect: ScarletUI.Rect, paint: ScarletUI.Paint) {}
}
