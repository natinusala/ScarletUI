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

import Quick
import Backtrace

@testable import ScarletCore

// Add every test target here
@testable import CoreUnitTests
@testable import CoreIntegrationTests
@testable import UITests

// Add every spec file here
let specs: [QuickSpec.Type] = [
    // MARK: CoreUnitTests

    TryEquatableSpec.self,
    AnyEqualsSpec.self,

    // MARK: CoreIntegrationTests

    // Common views
    UserViewSpec.QuickSpec.self,
    EmptyViewSpec.QuickSpec.self,
    TupleViewSpec.QuickSpec.self,
    ComplexViewSpec.QuickSpec.self,

    // Conditional views
    BalancedConditionalViewSpec.QuickSpec.self,
    UnbalancedConditionalViewSpec.QuickSpec.self,
    OptionalConditionalViewSpec.QuickSpec.self,
    EmptyConditionalViewSpec.QuickSpec.self,
    NestedConditionalViewSpec.QuickSpec.self,
    TopLevelNestedConditionalViewSpec.QuickSpec.self,
    ConsecutiveConditionalViewSpec.QuickSpec.self,
    ConditionalViewContentUpdateSpec.QuickSpec.self,

    // Optional views
    OptionalViewContentUpdateSpec.QuickSpec.self,
    OptionalViewToggleSpec.QuickSpec.self,
    OptionalViewToggleMultipleSpec.QuickSpec.self,
    NestedOptionalViewSpec.QuickSpec.self,
    NestedOptionalViewContentUpdateSpec.QuickSpec.self,

    // View modifiers
    ViewModifierBodySpec.QuickSpec.self,
    MultipleViewModifierSpec.QuickSpec.self,
    NestedViewModifierSpec.QuickSpec.self,
    ViewModifierStateSpec.QuickSpec.self,
    ViewModifierTogglingContentSpec.QuickSpec.self,

    // Environment
    EnvironmentValueSpec.QuickSpec.self,
    EnvironmentUpdatesSpec.QuickSpec.self,
    EnvironmentSameValueSpec.QuickSpec.self,
    EnvironmentStateSpec.QuickSpec.self,

    // Attributes
    AttributeSpec.QuickSpec.self,
    AttributesMultipleSpec.QuickSpec.self,
    AttributesDifferentSpec.QuickSpec.self,
    AttributeSpreadingSpec.QuickSpec.self,
    AttributeNonPropagationSpec.QuickSpec.self,
    AccumulatingAttributeMutlipleSpec.QuickSpec.self,
    AccumulatingAttributeSpec.QuickSpec.self,
    AccumulatingAttributeMultipleDifferentSpec.QuickSpec.self,
    AccumulatingAttributeWrongTypeSpec.QuickSpec.self,
    AccumulatingAttributeMultipleWrongTypeSpec.QuickSpec.self,
    AccumulatingAttributeAccumulationSpec.QuickSpec.self,
    AccumulatingAttributeSpreadingSpec.QuickSpec.self,
    AccumulatingAttributeMultiplePropagationSpec.QuickSpec.self,
    AccumulatingAttributeNonPropagationSpec.QuickSpec.self,
    EnvironmentAttributePropagationSpec.QuickSpec.self,
    EnvironmentAttributePropagationOverridingSpec.QuickSpec.self,
    EnvironmentAttributeAlreadySetSpec.QuickSpec.self,

    // Dynamic edges
    // ForEachSpecs.self,

    // MARK: UITests
    RowUITests.self,
    ColumnUITests.self,
    PaddingUITests.self,
]

// XXX: A main struct will be required as long as top-level code
// detection isn't fixed for `XCTMain.swift`
@main
struct Main {
    static func main() {
        Backtrace.install()
        ScarletCore.bootstrap(testing: true)
        QCKMain(specs + [TeardownSpec.self])
    }
}

private class TeardownSpec: QuickSpec {
    override func spec() {
        describe("ScarletCore tests") {
            context("when finished") {
                it("tears down") {
                    ScarletCore.teardown()
                }
            }
        }
    }
}
