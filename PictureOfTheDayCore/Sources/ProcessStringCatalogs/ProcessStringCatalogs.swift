import Foundation

@main
@available(macOS 13.0.0, *)
struct ProcessStringCatalogs {
  static func main() async throws {
    // Use swift-argument-parser or just CommandLine, here we just imply that 2 paths are passed in: input and output
    guard CommandLine.arguments.count == 3 else {
      throw CodeGeneratorError.invalidArguments
    }
    // arguments[0] is the path to this command line tool
    let input = URL(filePath: CommandLine.arguments[1])
    let output = URL(filePath: CommandLine.arguments[2])

    let jsonData = try Data(contentsOf: input)
    try jsonData.write(to: output, options: .atomic)
  }
}

@available(macOS 13.00.0, *)
enum CodeGeneratorError: Error {
  case invalidArguments
  case invalidData
}
