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

public protocol ElementImplementation {
    /// Creates a new implementation with the given view "display name".
    init(displayName: String)

    /// Inserts the given child implementation at the given position.
    func insert(child: any ElementImplementation, at index: Int)

    /// Removes the child at the given position.
    func remove(at index: Int)
}

/// Proxy for manipulating an element's implementation in a type-erased manner.
/// TODO: Remove and merge in View once we have Swift 5.7 and unlocked existentials. Store the view directly in the output.
public struct ImplementationProxy {
    var makeClosure: () -> [ElementImplementation]
    var updateClosure: (_ implementation: ElementImplementation) -> ()

    init<V: View>(of view: V) {
        self.makeClosure = {
            V.makeImplementations(of: view)
        }

        self.updateClosure = { implementation in
            guard let typedImplementation = implementation as? V.Implementation else {
                fatalError("Tried to update an implementation with an implementation of the wrong type")
            }

            V.updateImplementation(typedImplementation, with: view)
        }
    }

    init() {
        self.makeClosure = { [] }
        self.updateClosure = { _ in }
    }

    func make() -> [ElementImplementation] {
        return self.makeClosure()
    }

    func update(implementation: ElementImplementation) {
        return self.updateClosure(implementation)
    }
}

public extension View {
    var implementationProxy: ImplementationProxy {
        return ImplementationProxy(of: self)
    }
}

extension Never: ElementImplementation {
    public typealias Element = Never

    public var children: [ElementImplementation] {
        fatalError()
    }

    public init(displayName: String) {
        fatalError()
    }

    public func insert(child: ElementImplementation, at index: Int) {
        fatalError()
    }

    public func remove(at index: Int) {
        fatalError()
    }
}
