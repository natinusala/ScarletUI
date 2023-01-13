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

import Foundation
import GLFW

extension GLFWgamepadstate {
    /// Returns buttons state as an array, since Swift returns fixed length C arrays
    /// as Swift tuples (here it's a 15 members tuple).
    var buttonsArrays: [UInt8] {
        withUnsafeBytes(of: self.buttons) { buf in
            [UInt8](buf)
        }
    }
}

extension PhysicalGamepadButton {
    /// GLFW button associated to this Scarlet button.
    var glfwButton: Int? {
        switch self {
            case .a: return Int(GLFW_GAMEPAD_BUTTON_A)
            case .b: return Int(GLFW_GAMEPAD_BUTTON_B)
            case .x: return Int(GLFW_GAMEPAD_BUTTON_X)
            case .y: return Int(GLFW_GAMEPAD_BUTTON_Y)
            case .back: return Int(GLFW_GAMEPAD_BUTTON_BACK)
            case .start: return Int(GLFW_GAMEPAD_BUTTON_START)
            case .guide: return Int(GLFW_GAMEPAD_BUTTON_GUIDE)
            case .dpadUp: return Int(GLFW_GAMEPAD_BUTTON_DPAD_UP)
            case .dpadDown: return Int(GLFW_GAMEPAD_BUTTON_DPAD_DOWN)
            case .dpadLeft: return Int(GLFW_GAMEPAD_BUTTON_DPAD_LEFT)
            case .dpadRight: return Int(GLFW_GAMEPAD_BUTTON_DPAD_RIGHT)
            case .leftThumb: return Int(GLFW_GAMEPAD_BUTTON_LEFT_THUMB)
            case .rightThumb: return Int(GLFW_GAMEPAD_BUTTON_RIGHT_THUMB)
            case .leftBumper: return Int(GLFW_GAMEPAD_BUTTON_LEFT_BUMPER)
            case .rightBumper: return Int(GLFW_GAMEPAD_BUTTON_RIGHT_BUMPER)
            case .debug: return nil
        }
    }

    /// Returns `true` if the associated keyboard key is pressed.
    func isAssociatedKeyboardKeyPressed(window handle: OpaquePointer?) -> Bool {
        let key: Int32?
        switch self {
            case .dpadLeft: key = Int32(GLFW_KEY_LEFT)
            case .dpadRight: key = Int32(GLFW_KEY_RIGHT)
            case .dpadUp: key = Int32(GLFW_KEY_UP)
            case .dpadDown: key = Int32(GLFW_KEY_DOWN)
            default: key = nil // TODO: Add other keys and remove default
        }

        if let key = key {
            return glfwGetKey(handle, key) == GLFW_PRESS
        }

        return false
    }
}

extension GLFWWindow {
    func pollGamepad() -> _PhysicalGamepadState {
        var glfwState = GLFWgamepadstate()
        glfwGetGamepadState(GLFW_JOYSTICK_1, &glfwState)

        return _PhysicalGamepadState(
            buttons: PhysicalGamepadButton.allCases.map { button in
                // Real gamepad buttons associated to a GLFW button
                if let glfwButton = button.glfwButton {
                    return glfwState.buttonsArrays[glfwButton] == GLFW_PRESS || button.isAssociatedKeyboardKeyPressed(window: self.handle)
                }

                // Special buttons with no associated GLFW button
                switch button {
                    case .debug:
                        return glfwGetKey(handle, GLFW_KEY_F12) == GLFW_PRESS
                    default:
                        return false
                }
            }
        )
    }
}
