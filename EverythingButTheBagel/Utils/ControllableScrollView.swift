import SwiftUI
import ComposableArchitecture
import EverythingButTheBagelCore

struct ControllableScrollView<Content: View>: View {
  @Bindable var store: StoreOf<Scroll>

  let content: Content

  init(store: StoreOf<Scroll>, @ViewBuilder content: () -> Content) {
    self.store = store
    self.content = content()
  }

  var body: some View {
    ScrollView {
      ZStack {
        content
        ScrollTracker(
          store: store.scope(state: \.tracker, action: \.tracker)
        )
      }.scrollTargetLayout()
    }
    .scrollPosition(id: $store.trackerId.sending(\.setTracker))
  }
}

struct ScrollTracker: View {
  static let id = "tracker"
  let store: StoreOf<ScrollTrackerReducer>

  var body: some View {
    VStack {
      GeometryReader { geometry in
        Rectangle()
          .frame(height: 2)
          .foregroundStyle(Color.red)
          .onChange(of: geometry.frame(in: .scrollView(axis: .vertical))) {
            let scrollGeometry = geometry.frame(in: .scrollView(axis: .vertical))
            let verticalOffset = scrollGeometry.origin.y
            store.send(.scroll(position: verticalOffset))
          }
      }
      Spacer(minLength: -store.totalOffset)
      Rectangle()
        .frame(height: 10)
        .foregroundStyle(Color.red)
        .id(ScrollTracker.id)
      Spacer()
        .layoutPriority(1)
    }
  }
}
