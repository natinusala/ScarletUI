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

extension _PhysicalGamepadState {
    /// Takes physical buttons state and resolves virtual buttons state.
    /// The index is the button index inside ``VirtualGamepadButton``.
    func translateToVirtual() -> [Bool] {
        // TODO: Add virtual buttons
        // TODO: Perform axis translation
        return [Bool](repeating: false, count: VirtualGamepadButton.allCases.count)
    }

    /// Takes the physical gamepad state and converts it to an internal gamepad
    /// representation.
    func process(previous: _GamepadState) -> _GamepadState {
        return _GamepadState(
            physicalButtons: zip(self.buttons, previous.physicalButtons).map { (pressed, previous) in
                Self.buttonState(pressed: pressed, previousState: previous)
            },
            virtualButtons: zip(self.translateToVirtual(), previous.virtualButtons).map { (pressed, previous) in
                Self.buttonState(pressed: pressed, previousState: previous)
            }
        )
    }

    /// Takes the previous state for a button and returns the new one.
    private static func buttonState(pressed: Bool, previousState: _ButtonState) -> _ButtonState {
        switch (pressed, previousState) {
            case (false, .released), (true, .pressed):
                return previousState
            case (false, .pressed):
                return .released
            case (true, .released):
                return .pressed(since: Date(), consumed: false)
        }
    }
}

/// State of a physical gamepad.
/// Simplest representation possible to make it easier to implement on multiple platforms.
public struct _PhysicalGamepadState {
    /// Buttons state.
    /// `true` means pressed, `false` means released.
    /// The index is the button index inside ``PhysicalGamepadButton``.
    var buttons: [Bool]

    /// Gamepad state with no buttons pressed and all axis to neutral.
    static let neutral = _PhysicalGamepadState(buttons: [Bool](repeating: false, count: PhysicalGamepadButton.allCases.count))
}

/// Gamepad state as held by the app.
/// Contains virtual buttons as well as additional state on each button.
public struct _GamepadState {
    var physicalButtons: [_ButtonState]
    var virtualButtons: [_ButtonState]

    /// Gamepad state with no buttons pressed and all axis to neutral.
    static let neutral = _GamepadState(
        physicalButtons: [_ButtonState](repeating: .released, count: PhysicalGamepadButton.allCases.count),
        virtualButtons: [_ButtonState](repeating: .released, count: VirtualGamepadButton.allCases.count)
    )

    mutating func consume(_ button: GamepadButton, at idx: Int) {
        switch button {
            case .physical:
                self.physicalButtons[idx] = self.physicalButtons[idx].consumed
            case .virtual:
                self.virtualButtons[idx] = self.virtualButtons[idx].consumed
        }
    }
}

/// State of a gamepad button.
enum _ButtonState {
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

    var consumed: Self {
        switch self {
            case .pressed(let since, _):
                return .pressed(since: since, consumed: true)
            case .released:
                return .released
        }
    }
}
