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
    case b = 1

    /// X button.
    case x = 2

    /// Y button.
    case y = 3

    /// DPAD up.
    case dpadUp = 4

    /// DPAD right.
    case dpadRight = 5

    /// DPAD down.
    case dpadDown = 6

    /// DPAD left.
    case dpadLeft = 7

    /// Start button.
    case start = 8

    /// Back button, also called "select".
    case back = 9

    /// Guide button (big glowing "X" button in the middle).
    case guide = 10

    /// Left analog thumbstick button.
    case leftThumb = 11

    /// Right analog thumbstick button.
    case rightThumb = 12

    /// Left shoulder bumper button.
    case leftBumper

    /// Right shoulder bumper button.
    case rightBumper = 14

    /// Virtual button mapped to the left shoulder trigger axis.
    case virtualLeftTrigger = 15

    /// Virtual button mapped to the right shoulder trigger axis.
    case virtualRightTrigger = 16

    /// Virtual button mapped to DPAD up and the corresponding left analog stick axis.
    case virtualUp = 17

    /// Virtual button mapped to DPAD right and the corresponding left analog stick axis.
    case virtualRight = 18

    /// Virtual button mapped to DPAD down and the corresponding left analog stick axis.
    case virtualDown = 19

    /// Virtual button mapped to DPAD left and the corresponding left analog stick axis.
    case virtualLeft = 20
}
