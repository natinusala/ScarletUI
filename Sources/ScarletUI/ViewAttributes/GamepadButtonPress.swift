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

public extension View {
    /// Adds an action to perform when a gamepad button is pressed while this view is on screen.
    /// The action must return `true` if the event has been consumed. Otherwise it will be passed to the view's children.
    /// Note: the action will be performed even if the view is out of sight.
    func onGamepadButtonPress(perform action: @escaping _GamepadButtonPressCallback) -> some View {
        return self.attributed(
            AppendAttribute(\_ViewImplementation.gamepadButtonPressAction, value: action)
        )
    }

    /// Adds an action to perform when a gamepad button is pressed while this view is on screen.
    /// Note: the action will be performed even if the view is out of sight.
    func onGamepadButtonPress(perform action: @escaping () -> Void) -> some View {
        let callback: _GamepadButtonPressCallback = { pressedButton in
            action()
            return true
        }

        return self.attributed(
            AppendAttribute(\_ViewImplementation.gamepadButtonPressAction, value: callback)
        )
    }

    /// Adds an action to perform when the given gamepad button is pressed while this view is on screen.
    /// Note: the action will be performed even if the view is out of sight.
    func onGamepadButtonPress(_ button: GamepadButton, perform action: @escaping () -> Void) -> some View {
        let callback: _GamepadButtonPressCallback = { pressedButton in
            if pressedButton == button {
                action()
                return true
            }

            return false
        }

        return self.attributed(
            AppendAttribute(\_ViewImplementation.gamepadButtonPressAction, value: callback)
        )
    }
}
