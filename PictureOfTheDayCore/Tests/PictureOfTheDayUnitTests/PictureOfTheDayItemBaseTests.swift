import XCTest
@testable import PictureOfTheDayCore
import ComposableArchitecture
@testable import EverythingButTheBagelCore
import FunctionSpy

final class PictureOfTheDayItemBaseTests: XCTestCase {
  @MainActor
  func testAsyncImageTask() async throws {
    let (readSpy, readFn) = spy({ (_: URL) in Data() })
    let (writeSpy, writeFn) = spy({ (_: URL, _: Data) in })
    let (existsSpy, existsFn) = spy({ (_: URL) in false })

    let store = TestStore(
      initialState: PictureOfTheDayItemBase.State(
        title: "Hey this is an image",
        asyncImage: .mock
      ),
      reducer: {
        PictureOfTheDayItemBase()
      },
      withDependencies: { dependencies in
        dependencies[DataRequestClient<Data>.self] = DataRequestClient(request: { _, _ in Data() })
        dependencies.uuid = .incrementing
        dependencies.fileClient = FileClient(read: readFn, write: writeFn, exists: existsFn)
      }
    )

    // After task gets hit, async image logic is triggered which is tested elsewhere
    store.exhaustivity = .off

    await store.send(.asyncImage(.viewModel(.delegate(.task))))
    await store.receive(\.asyncImage.dataSource.fetch)
  }
}
