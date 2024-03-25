import SwiftUI
import TakehomeProjectBaseCore

@main
struct TakehomeProjectBaseApp: App {
    init() {
      TakehomeProjectBaseCore.appSetup()
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
