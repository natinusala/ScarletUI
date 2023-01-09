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

/// A button on a gamepad. Matches a standard XInput controller.
/// "Virtual" buttons are axis turned into buttons for convenience.
public enum GamepadButton: Int, CaseIterable {
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

    /// Virtual button mapped to the left shoulder trigger axis.
    case virtualLeftTrigger

    /// Virtual button mapped to the right shoulder trigger axis.
    case virtualRightTrigger

    /// Virtual button mapped to DPAD up and the corresponding left analog stick axis.
    case virtualUp

    /// Virtual button mapped to DPAD right and the corresponding left analog stick axis.
    case virtualRight

    /// Virtual button mapped to DPAD down and the corresponding left analog stick axis.
    case virtualDown

    /// Virtual button mapped to DPAD left and the corresponding left analog stick axis.
    case virtualLeft

    /// Debug button. Platform specific, not guaranteed to be available on standard controllers.
    case debug
}
