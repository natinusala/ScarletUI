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

import ScarletUI
import Dispatch
import Logging

ScarletUI.bootstrap()

let logger = Logger(label: "Graphics")

logger.debug("Available contexts: OpenGL, Vulkan")
logger.debug("Using OpenGL")
logger.info("1280x720 OpenGL window created")

let secondLogger = Logger(label: "Input")

secondLogger.debug("Available drivers: Xinput, udev")
secondLogger.debug("Using Xinput")
secondLogger.debug("Found Xbox Controller on slot #1")

secondLogger.info("Xbox Controller (slot 1) bound to player 1")

let timer = DispatchSource.makeTimerSource(queue: DispatchQueue.main)

var count = 0
timer.schedule(deadline: .now(), repeating: 1)
timer.setEventHandler {
    count += 1
    secondLogger.info("Tick \(count)")
}
timer.resume()

dispatchMain()
