import Testing
import ComposableArchitecture
import EverythingButTheBagelCore

struct AsyncImageViewModelTests {
  @Test func delegateTaskDoesNothing() async throws {
    let store = TestStore(
      initialState: AsyncImageViewModel.State(imageName: "Test", isLoading: false)
    ) {
      AsyncImageViewModel()
    }
    await store.send(.delegate(.task))
  }
}
