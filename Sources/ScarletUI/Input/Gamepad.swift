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

extension _GamepadState {
    /// Adds virtual buttons, performs axis translation...
    func toVirtual() -> _GamepadState {
        // TODO: Add virtual buttons
        // TODO: Perform axis translation

        return self
    }
}

/// State of a gamepad.
public struct _GamepadState {
    /// Buttons state.
    /// `true` means pressed, `false` means released.
    /// The index is the button index inside `GamepadButton`.
    var buttons: [ButtonState]

    /// Gamepad state with no buttons pressed and all axis to neutral.
    static let neutral = _GamepadState(buttons: [ButtonState](repeating: .released, count: GamepadButton.allCases.count))

    mutating func consume(idx: Int) {
        switch self.buttons[idx] {
            case .pressed(let since, _):
                self.buttons[idx] = .pressed(since: since, consumed: true)
            default:
                break
        }
    }
}

/// State of a gamepad button.
enum ButtonState {
    /// The button is released.
    case released

    /// The button is pressed since the given date.
    /// `consumed` will be `true` if a long press event has been fired for this
    /// button _before it was released_.
    case pressed(since: Date, consumed: Bool)

    var isLongPress: Bool {
        switch self {
            case .pressed(let since, _):
                return abs(Date().distance(to: since)) >= longPressDelay
            default:
                return false
        }
    }
}
