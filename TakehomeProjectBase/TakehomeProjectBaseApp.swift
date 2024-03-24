//
//  TakehomeProjectBaseApp.swift
//  TakehomeProjectBase
//
//  Created by fnord on 3/23/24.
//

import SwiftUI
import Sentry


@main
struct TakehomeProjectBaseApp: App {
    init() {
        SentrySDK.start { options in
            options.dsn = "https://262de3d8952cf58221fe4c6618834b64@o4506965171896320.ingest.us.sentry.io/4506965173207040"
            options.debug = true // Enabled debug when first installing is always helpful
            options.enableTracing = true 

            // Uncomment the following lines to add more data to your events
            // options.attachScreenshot = true // This adds a screenshot to the error events
            // options.attachViewHierarchy = true // This adds the view hierarchy to the error events
        }
        // Remove the next line after confirming that your Sentry integration is working.
        SentrySDK.capture(message: "This app uses Sentry! :)")
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
