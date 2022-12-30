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

import Backtrace
import Foundation

/// Implementation for all apps.
open class _AppImplementation: ImplementationNode, _TagImplementationNode {
    public let displayName: String

    /// Children of this app.
    var children: [_SceneImplementation] = []

    /// Run loop responsible for consuming and/or draining events.
    let runLoop = RunLoop.main

    /// Current platform handle
    let platform: any _Platform

    /// Should the app stop running?
    var exitRequested = false

    /// Signal sources retained by the app.
    var signalSources: [DispatchSourceSignal] = []

    public var tag: String?

    public required init(displayName: String) {
        self.displayName = displayName

        // Init platform
        do {
            guard let platform = try createPlatform() else {
                appLogger.error("No compatible platform found, is your platform supported?")
                exit(-1)
            }

            self.platform = platform
        } catch {
            appLogger.error("Cannot initialize platform: \(error.qualifiedName)")
            exit(-1)
        }

        appLogger.info("Using platform \(self.platform.name)")
    }

    public func attributesDidSet() {

    }

    public func insertChild(_ child: ImplementationNode, at position: Int) {
        guard let child = child as? _SceneImplementation else {
            fatalError("Cannot add \(type(of: child)) as child of '_AppImplementation'")
        }

        self.children.insert(child, at: position)
        child.parent = self

        // Attributes are set, it's been added to the list, call `create(platform:)` on the child
        child.create(platform: self.platform)
    }

    public func removeChild(at position: Int) {
        self.children.remove(at: position)
    }

    /// Runs the app for one frame.
    /// Returns `true` if the app should exit.
    func frame() -> Bool {
        // Poll events
        self.platform.pollEvents()

        // Run the scene for one frame, if any
        guard let scene = self.children[safe: 0] else {
            return false
        }

        // Poll inputs
        scene.updateInputs()

        // Run scene frame
        return scene.frame()
    }

    /// Runs the app until closed by the user.
    func run() {
        // Handle stop signals
        for signal in [SIGINT, SIGTERM] {
            let source = DispatchSource.makeSignalSource(signal: signal, queue: .main)
            source.setEventHandler { [weak self] in
                guard let self else { return }

                print()
                self.exitRequested = true
            }
            source.resume()

            self.signalSources.append(source)
        }

        while true {
            // Run one frame
            let (frameBegin, frameTime, windowClosed) = stopwatch {
                self.frame()
            }

            // If a target frame time is specified and we are below it, run the loop until next frame
            // Otherwise run the loop for half a frame (arbitrary)
            let runLoopUntil: Date
            if targetFrameTime > 0 && frameTime < targetFrameTime {
                runLoopUntil = frameBegin.advanced(by: targetFrameTime)
            } else {
                runLoopUntil = frameBegin.advanced(by: targetFrameTime / 2)
            }

            if !self.runLoop.run(mode: .default, before: runLoopUntil) {
                appLogger.warning("Runloop did not run for this frame!")
            }

            // Exit if necessary
            if windowClosed || self.exitRequested {
                appLogger.info("Exiting...")
                break
            }
        }
    }

    /// Runs the specified closure and returns how long it took to run.
    private func stopwatch<Result>(_ closure: () -> Result) -> (Date, TimeInterval, Result) {
        let begin = Date()
        let result = closure()
        return (begin, begin.distance(to: Date()), result)
    }

    public var tagChildren: [any _TagImplementationNode] {
        return self.children.map { $0 as any _TagImplementationNode }
    }
}

public extension App {
    /// Default implementation type for scenes.
    typealias Implementation = _AppImplementation
}

public extension App {
    static func main() {
        Backtrace.install()
        let arguments = ScarletCore.bootstrap()

        let app = Self.init()

#if DEBUG
        // Handle debug arguments and preview
        appLogger.info("Running in debug configuration")

        if Self.runForPreviewIfNeeded(arguments: arguments) {
            return
        }
#endif

        // Run the app normally by making the app node at top level
        let root = Self.makeNode(of: app, in: nil, implementationPosition: 0, using: .root())

        guard let implementation = root.implementation as? _AppImplementation else {
            fatalError("No implementation found for app node or got implementation of the wrong type")
        }

        implementation.run()
    }
}
