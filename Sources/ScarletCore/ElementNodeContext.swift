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
public struct ElementNodeContext {
    /// Attributes pending to be set, coming from above in the graph.
    let attributes: AttributesStash

    /// Stack of `ViewModifierContentContext` for view modifiers.
    let vmcStack: [ViewModifierContentContext]

    /// Has any state property changed?
    let hasStateChanged: Bool

    /// Has any dynamic variable changed?
    var dynamicVariableChanged: Bool {
        return hasStateChanged
    }

    /// Creates a copy of the context with another VMC context pushed on the stack.
    func pushingVmcContext(_ context: ViewModifierContentContext) -> Self {
        return Self(
            attributes: self.attributes,
            vmcStack: self.vmcStack + [context],
            hasStateChanged: self.hasStateChanged
        )
    }

    /// Creates a copy of the context with the last VMC context popped from the stack.
    func poppingVmcContext() -> (vmcContext: ViewModifierContentContext?, context: Self) {
        return (
            vmcContext: self.vmcStack.last,
            context: Self(
                attributes: self.attributes,
                vmcStack: self.vmcStack.dropLast(),
                hasStateChanged: self.hasStateChanged
            )
        )
    }

    /// Creates a copy of the context popping the attributes corresponding to the given implementation type,
    /// returning them along the context copy.
    func poppingAttributes<Implementation: ImplementationNode>(for implementationType: Implementation.Type) -> (attributes: [any AttributeSetter], context: Self) {
        Logger.debug(debugAttributes, "Searching for attributes to apply on \(Implementation.self)")

        // If we request attributes for `Never` just return empty attributes and the untouched context since
        // we can never have attributes for a `Never` implementation type
        if Implementation.self == Never.self {
            return (
                attributes: [],
                context: self
            )
        }

        // Create a new attributes stash containing only the corresponding attributes
        // then return that, as well as a new context containing all remaining attributes
        var newStash: [any AttributeSetter] = []
        var remainingAttributes = AttributesStash()

        for (target, attribute) in self.attributes {
            if attribute.applies(to: implementationType) {
                Logger.debug(debugAttributes, "Selected attribute for applying")
                newStash.append(attribute)

                // If the attribute needs to be propagated, put it back in the remaining attributes
                if attribute.propagate {
                    Logger.debug(debugAttributes, "     Attribute is propagated, putting it back for the edges")
                    remainingAttributes[target] = attribute
                }
            } else {
                Logger.debug(debugAttributes, "Selected attribute for the edges (\(attribute.implementationType) isn't applyable on \(Implementation.self))")
                remainingAttributes[target] = attribute
            }
        }

        return (
            attributes: newStash,
            context: Self(
                attributes: remainingAttributes,
                vmcStack: self.vmcStack,
                hasStateChanged: self.hasStateChanged
            )
        )
    }

    /// Returns a copy of the context with additional attributes added.
    /// Existing attributes will not be overwritten, hence the name "completing".
    func completingAttributes(from stash: AttributesStash) -> Self {
        let newStash = stash.merging(with: self.attributes)

        return Self(
            attributes: newStash,
            vmcStack: self.vmcStack,
            hasStateChanged: self.hasStateChanged
        )
    }

    /// Returns a copy of the context with the state change flag cleared.
    func clearingStateChange() -> Self {
        return ElementNodeContext(
            attributes: self.attributes,
            vmcStack: self.vmcStack,
            hasStateChanged: false
        )
    }

    /// Returns a copy of the context with the state change flag set.
    func settingStateChange() -> Self {
        return ElementNodeContext(
            attributes: self.attributes,
            vmcStack: self.vmcStack,
            hasStateChanged: true
        )
    }

    /// Returns the initial root context.
    public static func root() -> Self {
        return Self(
            attributes: AttributesStash(),
            vmcStack: [],
            hasStateChanged: false
        )
    }
}