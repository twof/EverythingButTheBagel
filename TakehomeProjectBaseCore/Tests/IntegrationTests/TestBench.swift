import XCTest

class TestBench: XCTestCase {
  func testBench() async throws {
    let urlRequest = URLRequest(url: URL(string: "https://catfact.ninja/fact")!, cachePolicy: .returnCacheDataElseLoad)
    
    let session = URLSession.shared
    let (data, _) = try await session.data(for: urlRequest)
    print(String(data: data, encoding: .utf8)!)
    
    let (data2, _) = try await session.data(for: urlRequest)
    print(String(data: data2, encoding: .utf8)!)
  }
}
