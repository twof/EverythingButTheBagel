import SwiftUI
import EverythingButTheBagelCore

@main
struct EverythingButTheBagelApp: App {
    init() {
      EverythingButTheBagelCore.appSetup()
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
