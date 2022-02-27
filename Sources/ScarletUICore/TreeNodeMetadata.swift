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

/// Metadata for a tree node (app, scene of view).
protocol TreeNodeMetadata: EquatableStruct {
    // Add necessary methods to test views if in a testing environment
    // Since `MountedView` stores a `TreeNodeMetadata` instance
    #if TESTING
        /// The expected initial tree starting from this view down to every child.
        var expectedInitialTree: BodyNode { get }

        /// Mutates view input to go to the initial body to the new tree.
        mutating func mutateInput()

        /// The expected tree after `mutateInput()` is called, starting from this view down to every child.
        var expectedMutatedTree: BodyNode { get }
    #endif
}

/// Used internally by the library to compare a struct using
/// `Equatable` conformance or field by field using generated code otherwise.
protocol EquatableStruct {
    /// Returns `true` if both given instances are equal.
    static func equals(lhs: Self, rhs: Self) -> Bool
}

extension EquatableStruct where Self: Equatable {
    /// Default implementation for `equals(lhs:rhs:)` for types that conform to `Equatable`.
    static func equals(lhs: Self, rhs: Self) -> Bool {
        return lhs == rhs
    }
}
