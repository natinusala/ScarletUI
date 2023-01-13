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

public protocol View: Element {
    associatedtype Body: View

    @ElementBuilder var body: Body { get }
}

/// Extension for internal views that have no body but
/// are not leaves (optionals, conditionals, tuple views...).
public extension View where Body == Never {
    var body: Never {
        fatalError("View `\(Self.displayName)` has body type `Never`, which is illegal - please use `LeafView` instead")
    }
}

extension ElementBuilder {
    public static func buildBlock() -> OptionalView<Never> {
        return .none
    }

    public static func buildBlock<Content>(_ content: Content) -> Content where Content: View {
        return content
    }
}

public typealias ViewBuilder = ElementBuilder

/// A view that only contains other views. Does not perform equality check on itself
/// since it would be redundant with checking its content view.
/// Set ``Target`` to `Never` if you don't need an target node.
public protocol ContainerView: View {}
