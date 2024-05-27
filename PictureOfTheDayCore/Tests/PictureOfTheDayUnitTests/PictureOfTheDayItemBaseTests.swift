import XCTest
@testable import PictureOfTheDayCore
import ComposableArchitecture
@testable import EverythingButTheBagelCore

final class PictureOfTheDayItemBaseTests: XCTestCase {
  @MainActor
  func testAsyncImageTask() async throws {
    let store = TestStore(
      initialState: PictureOfTheDayItemBase.State(
        title: "Hey this is an image",
        asyncImage: .init(imageUrl: URL(string: "https://apod.nasa.gov/apod/image/1809/Ryugu01_Rover1aHayabusa2_960.jpg")!)
      ),
      reducer: {
        PictureOfTheDayItemBase()
      },
      withDependencies: { dependencies in
        dependencies[DataRequestClient<Data>.self] = DataRequestClient(request: { _, _ in Data() })
        dependencies.uuid = .incrementing
      }
    )

    // After task gets hit, async image logic is triggered which is tested elsewhere
    store.exhaustivity = .off

    await store.send(.viewModel(.asyncImage(.delegate(.task))))
    await store.receive(\.asyncImage.dataSource.fetch)
  }
}
