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

/// Context given by the parent node to its edges when updating them.
public struct ComponentContext {
    /// Attributes pending to be set, coming from above in the graph.
    let attributes: AttributesStash

    /// Stack of `ViewModifierContentContext` for view modifiers.
    let vmcStack: [ViewModifierContentContext]

    /// Has any state property changed?
    let hasStateChanged: Bool

    /// Contains all environment values.
    let environment: EnvironmentValues

    /// List of all changed environment values.
    let changedEnvironment: EnvironmentDiff

    /// Creates a copy of the context with another VMC context pushed on the stack.
    func pushingVmcContext(_ context: ViewModifierContentContext) -> Self {
        return Self(
            attributes: self.attributes,
            vmcStack: self.vmcStack + [context],
            hasStateChanged: self.hasStateChanged,
            environment: self.environment,
            changedEnvironment: self.changedEnvironment
        )
    }

    /// Creates a copy of the context with the last VMC context popped from the stack.
    func poppingVmcContext() -> (vmcContext: ViewModifierContentContext?, context: Self) {
        return (
            vmcContext: self.vmcStack.last,
            context: Self(
                attributes: self.attributes,
                vmcStack: self.vmcStack.dropLast(),
                hasStateChanged: self.hasStateChanged,
                environment: self.environment,
                changedEnvironment: self.changedEnvironment
            )
        )
    }

    /// Returns a copy of the context with the state change flag cleared.
    func clearingStateChange() -> Self {
        return Self(
            attributes: self.attributes,
            vmcStack: self.vmcStack,
            hasStateChanged: false,
            environment: self.environment,
            changedEnvironment: self.changedEnvironment
        )
    }

    /// Returns a copy of the context with the changed environment values cleared.
    func clearingEnvironment() -> Self {
        return Self(
            attributes: self.attributes,
            vmcStack: self.vmcStack,
            hasStateChanged: self.hasStateChanged,
            environment: EnvironmentValues(),
            changedEnvironment: [:]
        )
    }

    func withEnvironment(_ environment: EnvironmentValues, changed: EnvironmentDiff) -> Self {
        return Self(
            attributes: self.attributes,
            vmcStack: self.vmcStack,
            hasStateChanged: self.hasStateChanged,
            environment: environment,
            changedEnvironment: changed
        )
    }

    /// Returns a copy of the context with the state change flag set.
    func settingStateChange() -> Self {
        return Self(
            attributes: self.attributes,
            vmcStack: self.vmcStack,
            hasStateChanged: true,
            environment: self.environment,
            changedEnvironment: self.changedEnvironment
        )
    }

    /// Returns the initial root context.
    public static func root() -> Self {
        return Self(
            attributes: AttributesStash(),
            vmcStack: [],
            hasStateChanged: false,
            environment: EnvironmentValues(), 
            changedEnvironment: [:]
        )
    }
}
