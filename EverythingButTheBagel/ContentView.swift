import SwiftUI
import ComposableArchitecture
import EverythingButTheBagelCore

struct ContentView: View {
  let store = Store(
    initialState: Scroll.State(tracker: ScrollTrackerReducer.State()),
    reducer: { Scroll(trackerId: ScrollTracker.id) }
  )
  var body: some View {
    Button("Down") {
      store.send(.scrollToPosition(store.tracker.totalOffset - 30))
    }
    ControllableScrollView(store: store) {
      LazyVStack {
        ForEach(0..<100) { index in
          Rectangle()
            .fill(Color.green.gradient)
            .frame(height: 50)
            .id("\(index)")
        }
      }
    }
  }
}

#Preview {
  ContentView()
}
