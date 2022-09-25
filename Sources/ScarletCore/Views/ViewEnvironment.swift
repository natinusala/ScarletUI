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
    public typealias Input = EnvironmentMakeInput<Self>
    public typealias Output = EnvironmentMakeOutput<Self, Content>
    public typealias Implementation = Never

    let keyPath: WritableKeyPath<EnvironmentValues, Value>
    let value: Value

    let content: Content

    public static func makeNode(
        of element: Self,
        in parent: (any ElementNode)?,
        implementationPosition: Int,
        using context: Context
    ) -> EnvironmentElementNode<Self, Content> where Input == EnvironmentMakeInput<Self> {
        return .init(making: element, in: parent, implementationPosition: implementationPosition, using: context)
    }

    public static func make(
        _ element: Self,
        input: EnvironmentMakeInput<Self>
    ) -> EnvironmentMakeOutput<Self, Content> {
        return .init(
            e0: element.content
        )
    }

    public static func collectEnvironment(of element: Self) -> (keyPath: WritableKeyPath<EnvironmentValues, Value>, value: Value) {
        return (keyPath: element.keyPath, value: element.value)
    }
}

public extension View {
    func environment<Value>(_ keyPath: WritableKeyPath<EnvironmentValues, Value>, value: Value) -> some View {
        return ViewEnvironment(keyPath: keyPath, value: value, content: self)
    }
}
