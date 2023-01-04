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

import Needler

protocol BodyAccessor: DebugInjectable {
    /// Makes the body of the given view.
    func makeBody<V: View>(of view: V) -> V.Body

    /// Makes the body of the given app.
    func makeBody<A: App>(of app: A) -> A.Body

    /// Makes the body of the given scene.
    func makeBody<S: Scene>(of scene: S) -> S.Body

    /// Makes the body of the given view modifier.
    func makeBody<VM: ViewModifier>(of modifier: VM) -> VM.Body
}

extension BodyAccessor {
    static var defaultValue: any BodyAccessor {
        return DefaultBodyAccessor()
    }
}

struct DefaultBodyAccessor: BodyAccessor {
    func makeBody<V: View>(of view: V) -> V.Body {
        return view.body
    }

    func makeBody<A: App>(of app: A) -> A.Body {
        return app.body
    }

    func makeBody<S: Scene>(of scene: S) -> S.Body {
        return scene.body
    }

    func makeBody<VM: ViewModifier>(of modifier: VM) -> VM.Body {
        return modifier.body(content: VM.Content())
    }
}
