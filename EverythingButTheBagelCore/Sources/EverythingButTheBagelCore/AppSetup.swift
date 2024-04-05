import Dependencies

/// All the setup needed by the core package. This function is expected to be called in the AppDelegate or SwiftUI App Initializer
public func appSetup() {
  // Registers with remote logging service
  @Dependency(\.loggingClient) var client
  client.setup()

  @Dependency(\.cacheConfiguration) var cacheConfig
  // Using the default config for now
  cacheConfig(nil, nil)
}
