import ComposableArchitecture
import XCTest
@testable import EverythingButTheBagelCore
import FunctionSpy

class CacheTests: XCTestCase {
  let model = ResponseModel(fact: "This is a test")
  var modelData: Data {
    try! JSONEncoder().encode(model)
  }
  let cacheKey = "test-cache"

  @MainActor
  func testCacheWrite() async throws {
    await withTestCache { cache, readSpy, writeSpy in
      cache.save(model)

      XCTAssertEqual(readSpy.callCount, 0)

      XCTAssertEqual(writeSpy.callCount, 1)
      XCTAssert(writeSpy.callParams[0].0.absoluteString.contains(cacheKey))
      XCTAssertEqual(writeSpy.callParams[0].1, modelData)
    }
  }

  @MainActor
  func testCacheRead() async throws {
    await withTestCache { cache, readSpy, writeSpy in
      let _: ResponseModel? = cache.load()

      XCTAssertEqual(readSpy.callCount, 1)
      XCTAssert(readSpy.callParams[0].absoluteString.contains(cacheKey))

      XCTAssertEqual(writeSpy.callCount, 0)
    }
  }

  @MainActor
  func testCacheReducer() async throws {
    try await withTestCache { cache, readSpy, writeSpy in
      let store = TestStore(initialState: ExampleReducer.State(fact: "")) {
        ExampleReducer().caching(cache: cache)
      }

      let fact = "new fact"

      await store.send(.updateFact(fact)) { state in
        state.fact = fact
      }

      let exampleState = ExampleReducer.State(fact: fact)
      let exampleData = try JSONEncoder().encode(exampleState)

      XCTAssertEqual(readSpy.callCount, 0)
      XCTAssertEqual(writeSpy.callCount, 1)
      XCTAssertEqual(writeSpy.callParams[0].1, exampleData)
    }
  }

  func withTestCache(
    closure: (DocumentsCache, _ readSpy: Spy1<URL>, _ writeSpy: Spy2<URL, Data>) async throws -> Void
  ) async rethrows {
    let (readSpy, readFn) = spy({ (_: URL) in self.modelData })
    let (writeSpy, writeFn) = spy({ (_: URL, _: Data) in })
    try await withDependencies { dependencies in
      dependencies.fileClient = FileClient(read: readFn, write: writeFn)
    } operation: {
      let cache = DocumentsCache(key: cacheKey)
      try await closure(cache, readSpy, writeSpy)
    }
  }
}

@Reducer
struct ExampleReducer {
  @ObservableState
  struct State: Codable, Equatable {
    var fact: String
  }

  enum Action {
    case updateFact(String)
  }

  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case let .updateFact(newFact):
        state.fact = newFact
        return .none
      }
    }
  }
}
