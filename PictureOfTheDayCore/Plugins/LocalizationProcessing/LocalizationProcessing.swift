import Foundation
import PackagePlugin

@main
struct LocalizationProcessing: BuildToolPlugin {
  func createBuildCommands(
    context: PackagePlugin.PluginContext,
    target: PackagePlugin.Target
  ) async throws -> [PackagePlugin.Command] {
    guard
      let stringCatalogFile = (target
        .sourceModule?
        .sourceFiles(withSuffix: ".xcstrings")
        .map { $0.url }
        .first)
    else {
      return []
    }

    let output = context.pluginWorkDirectoryURL.appending(component: "Localizable.json")
    return [
      .buildCommand(
        displayName: "Process String Catalogs",
        executable: try context.tool(named: "ProcessStringCatalogs").url,
        arguments: [stringCatalogFile.path(), output.path()],
        environment: [:],
        inputFiles: [stringCatalogFile],
        outputFiles: [output]
      )
    ]
  }
}
