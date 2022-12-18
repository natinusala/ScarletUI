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

import Runtime

public protocol ElementVisitor<Visited>: AnyObject {
    associatedtype Visited: Element

    func visitStateProperty<Value>(
        _ property: PropertyInfo,
        current: State<Value>,
        target: inout Visited,
        type: Value.Type
    ) throws

    func visitEnvironmentProperty<Value>(
        _ property: PropertyInfo,
        current: Environment<Value>,
        target: inout Visited,
        type: Value.Type,
        values: EnvironmentValues,
        diff: EnvironmentDiff
    ) throws
}
