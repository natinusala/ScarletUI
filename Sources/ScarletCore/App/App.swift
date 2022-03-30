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

/// A ScarletUI application.
/// An app is made of one scene, and a scene is made of one or multiple
/// views.
public protocol App {
    /// The type of this app's body.
    associatedtype Body: Scene

    /// This app's body.
    var body: Body { get }

    /// Creates an implementation of the given app.
    static func makeImplementation(app: Self) -> AppImplementation
}

/// The implementation of an app.
public protocol AppImplementation {

}