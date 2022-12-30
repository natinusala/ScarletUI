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

public struct UserMakeInput<Value>: ElementInput where Value: Element {

}

public struct UserMakeOutput<Value, Edge>: ElementOutput where Value: Element, Edge: Element {
    let edge: Edge
}

/// Element nodes for "user" elements with a body (apps, scenes, views, view modifiers...). Always performs equality checks.
public class UserElementNode<Value, Edge>: StatefulElementNode where Value: Element, Value.Input == UserMakeInput<Value>, Value.Output == UserMakeOutput<Value, Edge>, Edge: Element {
    public var value: Value
    public weak var parent: (any ElementNode)?
    public var implementation: Value.Implementation?
    public var implementationCount = 0
    public var attributes = AttributesStash()
    public var context: Context
    public var implementationPosition: Int

    var edge: Edge.Node?

    init(making element: Value, in parent: (any ElementNode)?, implementationPosition: Int, using context: Context) {
        self.value = element
        self.parent = parent
        self.context = context
        self.implementationPosition = implementationPosition

        // Set environment metadata for the type
        EnvironmentMetadataCache.shared.setCache(for: element)

        // Install the element
        var element = element
        self.install(element: &element, using: context)

        // Create the implementation node
        self.implementation = Value.makeImplementation(of: element)

        // Start a first update without comparing (since we update the value with itself)
        let result = self.update(with: element, implementationPosition: implementationPosition, using: context, initial: true)

        // Attach the implementation once everything is ready
        self.insertImplementationInParent(position: result.implementationPosition)
    }

    public func updateEdges(from output: Value.Output?, at implementationPosition: Int, using context: Context) -> UpdateResult {
        if let edge = self.edge {
            return edge.compareAndUpdate(with: output?.edge, implementationPosition: implementationPosition, using: context)
        } else if let output {
            let edge = Edge.makeNode(of: output.edge, in: self, implementationPosition: implementationPosition, using: context)
            self.edge = edge
            return UpdateResult(
                implementationPosition: implementationPosition,
                implementationCount: edge.implementationCount
            )
        } else {
            nilOutputFatalError(for: Edge.self)
        }
    }

    public func make(element: Value) -> Value.Output {
        let input = UserMakeInput<Value>()
        return Value.make(element, input: input)
    }

    public var allEdges: [(any ElementNode)?] {
        return [
            self.edge
        ]
    }
}
