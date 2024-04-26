import SwiftUI
import Shimmer
import PictureOfTheDayCore

struct PictureOfTheDayListItem: View {
  let vm: PictureOfTheDayViewModel

  var body: some View {
    HStack {
      Text(vm.title)
        .font(.body)
      Spacer()
    }
    .padding()
  }
}

extension PictureOfTheDayListItem {
  static let loadingPlaceholder: some View = PictureOfTheDayListItem(vm: .init(
    title: "ffff Example of a long cat fact, Example of a long cat fact, Example of a long cat fact, Example of a long cat fact")
  )
    .redacted(reason: .placeholder)
    .shimmering()
    .accessibilityLabel("Loading")
}

#Preview {
  Group {
    PictureOfTheDayListItem(vm: .init(title: "Example of a long cat fact, Example of a long cat fact, Example of a long cat fact, Example of a long cat fact"))

    PictureOfTheDayListItem.loadingPlaceholder
  }
}
