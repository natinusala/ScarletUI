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
