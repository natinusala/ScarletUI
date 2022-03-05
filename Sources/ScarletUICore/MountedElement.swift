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

/// A mounted app, scene or view, aka. the actual thing that's running in the app.
/// Must be a class for the state setter / body refresh process: the mounted element needs to escape
/// in the setter closure to be able to update itself (replace any changed child).
class MountedElement: CustomStringConvertible {
    var element: AnyElement {
        didSet {
            // If the element changes, call body again and compare the new body node
            // with the previous one (unless the element is a leaf node)
            if self.element.isLeaf {
                self.children = nil
            } else {
                let newBody = self.element.body
                self.children?.update(next: newBody)
            }
        }
    }

    /// The body node corresponding to this element's body.
    var children: BodyNode?

    /// Set to `true` to have this element be removed when possible.
    var toBeRemoved = false

    init(element: AnyElement) {
        self.element = element
    }

    var description: String {
        return String(describing: self.element.elementType)
    }
}
