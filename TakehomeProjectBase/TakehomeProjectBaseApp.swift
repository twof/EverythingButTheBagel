import SwiftUI
import Sentry


@main
struct TakehomeProjectBaseApp: App {
    init() {
        SentrySDK.start { options in
          options.dsn = "https://262de3d8952cf58221fe4c6618834b64@o4506965171896320.ingest.us.sentry.io/4506965173207040"
          options.enableTracing = true
        }
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
