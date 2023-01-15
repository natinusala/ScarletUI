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

protocol ScarletSpec {
    associatedtype Tested: TestView

    static var describing: String { get }

    typealias QuickSpec = ScarletSpecRunner<Self>
}

class ScarletSpecRunner<Spec: ScarletSpec>: QuickSpec {
    var view: Spec.Tested!
    var node: ComponentNode!

    var bodyAccessor: BodyAccessorMock!

    override func spec() {
        // We can build specs from `Spec.testing.spec()` directly as
        // the spec itself doesn't alter the view, running the cases inside
        // the `it` closure will
        describe(Spec.describing) {
            let specs = Spec.Tested.spec()

            for testCase in specs.cases {
                context("when \(testCase.description)") {
                    for expectation in testCase.expectations {
                        it("then \(expectation.description)") {
                            let initialSteps = testCase.initialSteps()

                            self.setupCase(with: initialSteps.initialView)
                            self.runCase(actions: initialSteps.updateActions, expectation: expectation)
                        }
                    }
                }
            }
        }
    }

    private func runCase(actions: [UpdateAction], expectation: Expectations) {
        // Execute the actions if any
        actions.forEach { $0.run(on: node) }

        // Make the result object and run the expectations closure
        let result = UpdateResult(
            bodyCalls: self.bodyAccessor.bodyCalls,
            target: self.node.target as? ViewTarget
        )

        expectation.closure(result)
    }

    private func setupCase(with node: ComponentNode) {
        // Rebuild the node from scratch to start each test case from a clean state
        self.node = node

        // Get a handle to the view from node storage once everything is installed
        guard let installedView = self.node.storage.value as? Spec.Tested else {
            fatalError("View was not installed")
        }

        self.view = installedView

        // Reset dependencies - do it after building the node to reset call counts
        self.bodyAccessor = BodyAccessorMock(wrapping: DefaultBodyAccessor())
        DefaultBodyAccessor.shared = self.bodyAccessor
    }
}

extension BodyAccessorMock {
    /// Body calls count by view type identifier.
    var bodyCalls: [ObjectIdentifier: Int] {
        var bodyCalls: [ObjectIdentifier: Int] = [:]

        // Views recording
        for (view, _) in self.makeBodyArgValues {
            let identifier = ObjectIdentifier(type(of: view))
            bodyCalls[identifier] = (bodyCalls[identifier] ?? 0) + 1
        }

        // View modifiers recording
        for (viewModifier, _) in self.makeBodyOfArgValues {
            let identifier = ObjectIdentifier(type(of: viewModifier))
            bodyCalls[identifier] = (bodyCalls[identifier] ?? 0) + 1
        }

        return bodyCalls
    }
}
