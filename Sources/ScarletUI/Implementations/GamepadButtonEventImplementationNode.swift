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

/// A node with "button pressed" and "button released" events.
protocol GamepadButtonEventImplementationNode {
    /// The children array, used to propagate the event.
    var children: [ViewImplementation] { get }

    /// Called every time a gamepad button is pressed.
    /// Must return `true` if the event was consumed, `false` if the event
    /// needs to be propagated to the children views.
    func gamepadButtonDidPress(_ button: GamepadButton) -> Bool

    /// Called every time a gamepad button is released.
    /// Must return `true` if the event was consumed, `false` if the event
    /// needs to be propagated to the children views.
    func gamepadButtonDidRelease(_ button: GamepadButton) -> Bool
}

extension GamepadButtonEventImplementationNode {
    /// Must be called to start a "button pressed" event on the view.
    func pressGamepadButton(_ button: GamepadButton) {
        if self.gamepadButtonDidPress(button) {
            return
        }

        for child in self.children {
            child.pressGamepadButton(button)
        }
    }

    /// Must be called to start a "button released" event on the view.
    func releaseGamepadButton(_ button: GamepadButton) {
        if self.gamepadButtonDidRelease(button) {
            return
        }

        for child in self.children {
            child.releaseGamepadButton(button)
        }
    }
}
