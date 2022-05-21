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

import Backtrace

import ScarletCore

/// Implementation for all apps.
open class AppImplementation: ImplementationNode, CustomStringConvertible {
    /// App display name for debugging purposes.
    let displayName: String

    /// Children of this app.
    var children: [SceneImplementation] = []

    /// Run loop responsible for consuming and/or draining events.
    let runLoop = RunLoop.main

    /// Current platform handle
    let platform: any Platform

    public required init(kind: ImplementationKind, displayName: String) {
        guard kind == .app else {
            fatalError("Tried to create a `ViewImplementation` with kind \(kind)")
        }

        self.displayName = displayName

        // Init platform
        do {
            guard let platform = try createPlatform() else {
                Logger.error("No compatible platform found, is your platform supported?")
                exit(-1)
            }

            self.platform = platform
        } catch {
            Logger.error("Cannot initialize platform: \(error.qualifiedName)")
            exit(-1)
        }

        Logger.info("Using platform \(self.platform.name)")
    }

    public func insertChild(_ child: ImplementationNode, at position: Int) {
        guard let child = child as? SceneImplementation else {
            fatalError("Cannot add \(type(of: child)) as child of `AppImplementation`")
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

    private let targetFrameTime = 0.016666666 // TODO: find a way for users to customize this somehow, put it in the scene?

    /// Runs the app until closed by the user.
    func run() {
        while true {
            // Run one frame
            let (frameBegin, frameTime, exit) = stopwatch {
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
                Logger.warning("Run loop could not be started!")
            }

            // Exit if necessary
            // TODO: Handle SIGINT here as well
            if exit {
                Logger.info("Exiting...")
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

    open func attributesDidSet() {
        // Nothing by default
    }

    public var description: String {
        return self.displayName
    }

    func printTree(indent: Int = 0) {
        let indentString = String(repeating: " ", count: indent)
        print("\(indentString)- \(self.description) (\(Self.self))")

        for child in self.children {
            child.printTree(indent: indent + 4)
        }
    }
}

public extension App {
    /// Default implementation for user apps.
    typealias Implementation = AppImplementation
}

public extension App {
    static func main() {
        Backtrace.install()

        let app = Self.init()
        let root = ElementGraph(parent: nil, position: 0, making: app)

        (root.implementation as! AppImplementation).run()
    }
}
