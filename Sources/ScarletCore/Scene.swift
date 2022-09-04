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

public protocol Scene: Element {
    /// Note: for the sake of simplicity, the body of a scene is a view. It's however
    /// possible to change that to `Scene` is composing scenes becomes required.
    /// "Final" scenes just need a special element node type taking a view
    /// as an edge (something like `SceneViewElementNode`) and no body call.
    associatedtype Body: View

    var body: Body { get }
}

/// Special protocol for scenes which content is a view.
/// Uses the `content` property instead of `body`.
public protocol LeafScene: Scene where Body == Never {
    associatedtype Content: View

    var content: Content { get }
}

public extension LeafScene{
    var body: Never {
        fatalError()
    }
}
