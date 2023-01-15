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

@testable import ScarletCore

protocol TestSignal {
    var rawValue: Int { get }
}

extension View {
    func onTestSignal(_ signal: any TestSignal, closure: @escaping () -> ()) -> some View {
        return self.attributed(
            AppendAttribute(\ViewTarget.signalHandlers, value: (signal, closure))
        )
    }
}

struct SignalUpdateAction: UpdateAction {
    let signal: any TestSignal

    func run(on node: any ComponentNode) {
        guard let target = node.target as? ViewTarget else {
            fatalError("Cannot signal an target node of type \(type(of: node.target))")
        }

        target.signal(signal)
    }
}

func signal(_ signal: any TestSignal) -> UpdateAction {
    return SignalUpdateAction(signal: signal)
}
