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

/// A mounted view, aka. the actual view that's running in the app.
/// Must be a class for the state setter / body refresh process: the mounted view needs to escape
/// in the setter closure to be able to update itself (replace any changed child).
class MountedView: CustomStringConvertible {
    var view: AnyElement {
        didSet {
            // If the view changes, call body again and compare the new body node
            // with the previous one (unless the view is a leaf node)
            if view.isLeaf {
                self.children = nil
            } else {
                let newBody = self.view.body
                self.children?.update(next: newBody)
            }
        }
    }

    /// The body node corresponding to this's view body.
    var children: BodyNode?

    /// Set to `true` to have this view be removed when possible.
    var toBeRemoved = false

    init(view: AnyElement) {
        self.view = view
    }

    var description: String {
        return String(describing: self.view.elementType)
    }
}
