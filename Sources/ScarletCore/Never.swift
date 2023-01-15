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

extension Never: ComponentInput, ComponentOutput {
    public typealias Model = Never
}

extension Never: TargetNode {
    public var displayName: String {
        fatalError()
    }

    public init(displayName: String) {
        fatalError()
    }

    public func attributesDidSet() {
        fatalError()
    }

    public func insertChild(_ child: TargetNode, at position: Int) {
        fatalError()
    }

    public func removeChild(at position: Int) {
        fatalError()
    }
}

extension Never: ComponentModel {
    public typealias Target = Never

    public static func makeNode(of component: Self, in parent: (any ComponentNode)?, targetPosition: Int, using context: Context) -> NeverComponentNode {}

    public static func make(_ component: Self, input: Never) -> Never {}

    public static func makeTarget(of component: Self) -> (any TargetNode)? {}
}

extension Never: View, Scene, App {
    public init() {
        fatalError()
    }

    public var body: Never {
        fatalError()
    }
}

public class NeverComponentNode: ComponentNode {
    public var model: Never {
        get {
            fatalError()
        }
        set {}
    }
    public weak var parent: (any ComponentNode)?
    public var target: Model.Target?
    public var targetCount = 0
    public var attributes = AttributesStash()

    init() {
        fatalError()
    }

    public func updateEdges(from output: Never?, at targetPosition: Int, using context: Context) -> UpdateResult {
        fatalError()
    }

    public func make(component: Never) -> Never {}

    public func shouldUpdate(with component: Never, using context: ComponentContext) -> Bool {}

    public var allEdges: [(any ComponentNode)?] {
        fatalError()
    }
}
