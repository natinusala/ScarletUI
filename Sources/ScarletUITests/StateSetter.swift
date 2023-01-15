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
import XCTest
import Dispatch
import Runtime

import ScarletUI
import ScarletCore

func setState<Node: StatefulComponentNode, Value>(named name: String, to value: Value, on node: Node) throws -> Bool {
    let visitor = StateSetterVisitor<Node.Model>(name: name, value: value)
    try visitor.walk(node.model, target: &node.model, using: node.context)
    return visitor.success
}

private class StateSetterVisitor<Visited: ComponentModel>: _DynamicPropertiesVisitor {
    let name: String
    let value: Any

    var success = false

    init(name: String, value: Any) {
        self.name = name
        self.value = value
    }

    func visitStateProperty<Value>(_ property: PropertyInfo, current: ScarletCore.State<Value>, target: inout Visited, type: Value.Type) throws {
        if property.name == "_\(self.name)" {
            guard let value = self.value as? Value else {
                XCTFail("Cannot set state property '\(self.name)' of type '\(Value.self)' to value of type '\(Swift.type(of: value))'")
                return
            }

            // XXX: Redispatch on main queue to prevent concurrency issues to prevent "simultaneous access"
            // since the visitor runs in an async context
            DispatchQueue.main.async {
                current.wrappedValue = value
            }

            self.success = true
        }
    }

    func visitEnvironmentProperty<Value>(_ property: PropertyInfo, current: ScarletCore.Environment<Value>, target: inout Visited, type: Value.Type, values: ScarletCore.EnvironmentValues, diff: ScarletCore.EnvironmentDiff) throws {}
}
