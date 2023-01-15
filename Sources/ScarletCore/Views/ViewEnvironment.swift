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

/// Setter for environment values on views.
public struct ViewEnvironment<Content: View, Value>: View, EnvironmentCollectable {
    public typealias Input = EnvironmentComponentInput<Self>
    public typealias Output = EnvironmentComponentOutput<Self, Content>
    public typealias Target = Never

    let keyPath: WritableKeyPath<EnvironmentValues, Value>
    let value: Value

    let content: Content

    public static func makeNode(
        of component: Self,
        in parent: (any ComponentNode)?,
        targetPosition: Int,
        using context: Context
    ) -> EnvironmentComponentNode<Self, Content> where Input == EnvironmentComponentInput<Self> {
        return .init(making: component, in: parent, targetPosition: targetPosition, using: context)
    }

    public static func make(
        _ component: Self,
        input: EnvironmentComponentInput<Self>
    ) -> EnvironmentComponentOutput<Self, Content> {
        return .init(
            e0: component.content
        )
    }

    public static func collectEnvironment(of component: Self) -> (keyPath: WritableKeyPath<EnvironmentValues, Value>, value: Value) {
        environmentLogger.trace("Collecting environment of \(Self.self)")
        return (keyPath: component.keyPath, value: component.value)
    }

    public var partialKeyPath: PartialKeyPath<EnvironmentValues> {
        return self.keyPath
    }
}

public extension View {
    func environment<Value>(_ keyPath: WritableKeyPath<EnvironmentValues, Value>, value: Value) -> some View {
        return ViewEnvironment(keyPath: keyPath, value: value, content: self)
    }
}
