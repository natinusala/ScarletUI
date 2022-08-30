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

// Add every test target here
@testable import ScarletCoreUnitTests
@testable import ScarletCoreIntegrationTests

// Add every spec file here
let specs: [QuickSpec.Type] = [
    // ScarletCoreUnitTests
    TryEquatableSpec.self,
    AnyEqualsSpec.self,

    // ScarletCoreIntegrationTests
    ViewSpecSpec.QuickSpec.self,
    EmptyViewSpecSpec.QuickSpec.self,
    TupleViewSpecSpec.QuickSpec.self,
    BalancedConditionalViewSpecSpec.QuickSpec.self,
    UnbalancedConditionalViewSpecSpec.QuickSpec.self,
    OptionalConditionalViewSpecSpec.QuickSpec.self,
    EmptyConditionalViewSpecSpec.QuickSpec.self,
    NestedConditionalViewSpecSpec.QuickSpec.self,
    TopLevelNestedConditionalViewSpecSpec.QuickSpec.self,
    ConsecutiveConditionalViewSpecSpec.QuickSpec.self,
    ConditionalViewContentUpdateSpec.QuickSpec.self,
    OptionalViewContentUpdateSpec.QuickSpec.self,
    OptionalViewToggleSpec.QuickSpec.self,
    NestedOptionalViewSpec.QuickSpec.self,
    NestedOptionalViewContentUpdateSpec.QuickSpec.self,
    ComplexViewSpec.QuickSpec.self,
    ViewModifierBodySpec.QuickSpec.self,
    MultipleViewModifierSpec.QuickSpec.self,
    NestedViewModifierSpec.QuickSpec.self,
    // ForEachSpecs.self,
]

// XXX: A main struct will be required as long as top-level code
// detection isn't fixed for `XCTMain.swift`
@main
struct Main {
    static func main() {
        Backtrace.install()
        QCKMain(specs)
    }
}
