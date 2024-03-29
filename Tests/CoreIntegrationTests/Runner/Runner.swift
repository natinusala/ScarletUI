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
import Needler

@testable import ScarletCore

protocol ScarletCoreSpec {
    associatedtype Tested: TestView

    static var describing: String { get }

    static var skipped: Bool { get }
}

extension ScarletCoreSpec {
    typealias QuickSpec = ScarletCoreSpecRunner<Self>
    static var skipped: Bool { false }
}

protocol Skipped: ScarletCoreSpec {}

extension Skipped {
    static var skipped: Bool { true }
}

class ScarletCoreSpecRunner<Spec: ScarletCoreSpec>: QuickSpec {
    typealias Tested = Spec.Tested

    var node: Tested.Node!

    var bodyAccessor: BodyAccessorMock!

    override func spec() {
        // Skip the whole test case if needed
        if Spec.skipped {
            return
        }

        // We can build specs from `Spec.testing.spec()` directly as
        // the spec itself doesn't alter the view, running the cases inside
        // the `it` closure will
        describe(Spec.describing) {
            let specs = Tested.spec()

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

    private func runCase(actions: [any UpdateAction], expectation: Expectations) {
        // Execute the actions if any
        actions.forEach { $0.run(on: self.node) }

        // Make the result object and run the expectations closure
        let result = UpdateResult(
            bodyCalls: self.bodyAccessor.bodyCalls,
            target: self.node.target as? ViewTarget
        )

        expectation.closure(result)
    }

    private func setupCase(with node: Tested.Node) {
        // Rebuild the node from scratch to start each test case from a clean state
        self.node = node

        // Reset dependencies and target flags - do it after building the node to reset call counts
        self.bodyAccessor = BodyAccessorMock(wrapping: DefaultBodyAccessor())
        DefaultBodyAccessor.shared = self.bodyAccessor

        guard let target = self.node.target as? ViewTarget else {
            fatalError("Cannot reset target, got '\(type(of: self.node.target))' instead of the expected 'ViewTarget'")
        }

        target.reset()
    }
}

extension BodyAccessorMock {
    /// Body calls count by view type identifier.
    var bodyCalls: [ObjectIdentifier: Int] {
        var bodyCalls: [ObjectIdentifier: Int] = [:]

        let recordings = self.makeBodyArgValues
            + self.makeBodyOfArgValues
            + self.makeBodyOfSSceneArgValues
            + self.makeBodyOfVMViewModifierArgValues

        for view in recordings {
            let identifier = ObjectIdentifier(type(of: view))
            bodyCalls[identifier] = (bodyCalls[identifier] ?? 0) + 1
        }

        return bodyCalls
    }
}
