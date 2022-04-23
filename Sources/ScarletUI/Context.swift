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

/// App runtime "context", aka. shared state.
class Context {
    /// Shared context instance.
    static let shared = Context()

    /// Current platform handle.
    let platform: any Platform

    private init() {
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
}
