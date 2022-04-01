import Dispatch
import Foundation

import AsyncHTTPClient

import ScarletNative

// TODO: add MainActor here once we have Swift 5.7 support
class RunLoop {
    /// Executed every frame.
    /// Returns `true` when the runloop should stop.
    typealias RunFunction = () -> Bool

    let runFunction: RunFunction
    let native = Foundation.RunLoop.main

    init(runFunction: @escaping RunFunction) {
        self.runFunction = runFunction
    }

    func run() {
        while true {
            let stop = self.runFunction()

            native.run(mode: .default, before: Date().advanced(by: 0.016666))

            if stop {
                break
            }
        }
    }
}

// TODO: test async let with real HTTP requests (real world use case)

func buttonClicked() async {
    print("Button clicked, changing image")

    await loadImage()

    print("Setting image to button")
}

func loadImage() async {
    print("Loading image")

    // try! await Task.sleep(nanoseconds: 500_000_000)

    let request = HTTPClientRequest(url: "https://www.fillmurray.com/3000/3000")
    let response = try! await httpClient.execute(request, timeout: .seconds(10))

    print("Done loading image, size:\(response.headers["content-size"])")
}

let httpClient = HTTPClient(eventLoopGroupProvider: .createNew)

let frames = 50
var count = 0

let loop = RunLoop {
    count += 1

    print("Frame \(count)")

    if count % 10 == 0 {
        print("Posting a task")
        Task {
            await buttonClicked()
        }
    }

    if count == frames {
        return true
    }

    return false
}

loop.run()


print("--- Program ended, back to Swift runtime ---")
