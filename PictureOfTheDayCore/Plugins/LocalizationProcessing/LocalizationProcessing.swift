import Foundation
import PackagePlugin

@main
struct LocalizationProcessing: BuildToolPlugin {
  func createBuildCommands(context: PackagePlugin.PluginContext, target: PackagePlugin.Target) async throws -> [PackagePlugin.Command] {
    guard
      let stringCatalogFile = (target
        .sourceModule?
        .sourceFiles(withSuffix: ".xcstrings")
        .map { $0.path }
        .first)
    else {
      return []
    }

    let output = context.pluginWorkDirectory.appending("Localizable.json")
    return [
      .buildCommand(
        displayName: "Process String Catalogs",
        executable: try context.tool(named: "ProcessStringCatalogs").path,
        arguments: [stringCatalogFile, output],
        environment: [:],
        inputFiles: [stringCatalogFile],
        outputFiles: [output]
      )
    ]
  }
}
