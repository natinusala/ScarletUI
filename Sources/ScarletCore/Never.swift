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

extension Never: MakeInput, MakeOutput {
    public typealias Value = Never
}

extension Never: ImplementationNode {
    public var displayName: String {
        fatalError()
    }

    public init(kind: ImplementationKind, displayName: String) {
        fatalError()
    }

    public func attributesDidSet() {
        fatalError()
    }

    public func insertChild(_ child: ImplementationNode, at position: Int) {
        fatalError()
    }

    public func removeChild(at position: Int) {
        fatalError()
    }
}

extension Never: Element {
    public static func makeNode(of element: Self, in parent: (any ElementNode)?, implementationPosition: Int, using context: Context) -> NeverElementNode {}

    public static func make(_ element: Self, input: Never) -> Never {}

    public static func makeImplementation(of element: Self) -> Never? {}
}

extension Never: View, Scene, App {
    public var body: Never {
        fatalError()
    }
}

public class NeverElementNode: ElementNode {
    public var value: Never {
        get {
            fatalError()
        }
        set {}
    }
    public var parent: (any ElementNode)?
    public var implementation: Never?
    public var implementationCount = 0

    init() {
        fatalError()
    }

    public func updateEdges(from output: Never, at implementationPosition: Int, using context: Context) -> UpdateResult {}

    public func make(element: Never) -> Never {}

    public func shouldUpdate(with element: Never) -> Bool {}

    public var allEdges: [(any ElementNode)?] {
        fatalError()
    }
}
