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

let targetFrameTime = 0.016666666 // TODO: find a way for users to customize this somehow, put it in the scene?

let defaultWindowWidth: Float = 1280.0
let defaultWindowHeight: Float = 720.0

/// How long to hold a button before it's considered a long press, in seconds.
let longPressDelay = 0.5

public extension Axis {
    static let `default` = Axis.column
}
