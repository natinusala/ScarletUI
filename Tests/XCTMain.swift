import Quick

// Add every test target here
@testable import ScarletUICoreTests

// Add every spec file here
let specs: [QuickSpec.Type] = [
    // ScarletUICoreTests
    ReconcilationSpecs.self,
]

@main
struct Main {
    public static func main() {
        QCKMain(specs)
    }
}
