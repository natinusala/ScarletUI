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
import Nimble

@testable import ScarletCore

protocol SpecDefinition {
    associatedtype Tested: TestView

    static var describing: String { get }
    static var testing: Tested { get }
}

class ScarletSpec<Definition: SpecDefinition>: QuickSpec {
    var view: Definition.Tested!
    var node: ElementNode!

    var bodyAccessor: BodyAccessorMock!

    override func spec() {
        beforeEach {
            // Rebuild the node from scratch to start each test case from a clean state
            let view: Definition.Tested = Definition.testing
            self.node = ElementNode(parent: nil, position: 0, making: view)

            // Get a handle to the view from node storage once everything is installed
            guard let installedView = self.node.storage.value as? Definition.Tested else {
                fatalError("View was not installed")
            }

            self.view = installedView

            // Reset dependencies - do it after building the node to reset call counts
            self.bodyAccessor = BodyAccessorMock(wrapping: DefaultBodyAccessor())
            Dependencies.bodyAccessor = self.bodyAccessor
        }

        // We can build specs from `Definition.testing.spec()` directly as
        // the definition itself doesn't alter the view, running the cases inside
        // the `it` closure will
        describe(Definition.describing) {
            let specs = Definition.testing.spec()

            for testCase in specs.cases {
                context("when \(testCase.description)") {
                    for expectation in testCase.expectations {
                        it("then \(expectation.description)") {
                            self.runCase(testCase, expectation: expectation)
                        }
                    }
                    
                }
            }
        }
    }

    private func runCase(_ testCase: Case, expectation: Expectations) {
        // Execute the action
        switch testCase.action {
        case .updateWith(let update):
            let view = update as! Definition.Tested
            self.node.update(with: view, attributes: [:])
        }

        // Make the result object and run the expectations closure
        let result = UpdateResult(
            bodyCalls: self.bodyAccessor.bodyCalls
        )

        expectation.closure(result)
    }
}
