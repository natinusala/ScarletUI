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

/// A physical button on a gamepad. Matches a standard XInput controller.
public enum PhysicalGamepadButton: Int, CaseIterable {
    /// A button.
    case a = 0

    /// B button.
    case b

    /// X button.
    case x

    /// Y button.
    case y

    /// DPAD up.
    case dpadUp

    /// DPAD right.
    case dpadRight

    /// DPAD down.
    case dpadDown

    /// DPAD left.
    case dpadLeft

    /// Start button.
    case start

    /// Back button, also called "select".
    case back

    /// Guide button (big glowing "X" button in the middle).
    case guide

    /// Left analog thumbstick button.
    case leftThumb

    /// Right analog thumbstick button.
    case rightThumb

    /// Left shoulder bumper button.
    case leftBumper

    /// Right shoulder bumper button.
    case rightBumper

    /// Debug button. Platform specific, not guaranteed to be available on standard controllers.
    case debug

    func toGamepadButton() -> (idx: Int, button: GamepadButton) {
        return (idx: self.rawValue, button: .physical(self))
    }
}

/// A virtual gamepad button, usually axis turned into buttons for convenience.
public enum VirtualGamepadButton: Int, CaseIterable {
    /// Virtual button mapped to the left shoulder trigger axis.
    case leftTrigger = 0

    /// Virtual button mapped to the right shoulder trigger axis.
    case rightTrigger

    /// Virtual button mapped to DPAD up and the corresponding left analog stick axis.
    case up

    /// Virtual button mapped to DPAD right and the corresponding left analog stick axis.
    case right

    /// Virtual button mapped to DPAD down and the corresponding left analog stick axis.
    case down

    /// Virtual button mapped to DPAD left and the corresponding left analog stick axis.
    case left

    func toGamepadButton() -> (idx: Int, button: GamepadButton) {
        return (idx: self.rawValue, button: .virtual(self))
    }
}

public enum GamepadButton: Equatable {
    case physical(_ button: PhysicalGamepadButton)
    case virtual(_ button: VirtualGamepadButton)
}
