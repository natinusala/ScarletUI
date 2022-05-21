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

// TODO: Allow multiple modifiers to be added by making a way to "append" attributes instead of
// simply setting them (they need to be identified to know which one to replace).

public struct GamepadButtonPressModifier: AttributeViewModifier {
    @Attribute(\ViewImplementation.gamepadButtonPressAction)
    var action

    public init(perform action: ((GamepadButton) -> ())?) {
        self.action = action
    }
}

public extension View {
    /// Adds an action to perform when a gamepad button is pressed while this view is on screen.
    /// Note: the action will be performed even if the view is out of sight.
    func onGamepadButtonPress(perform action: @escaping (GamepadButton) -> ()) -> some View {
        return modifier(GamepadButtonPressModifier(perform: action))
    }
}
