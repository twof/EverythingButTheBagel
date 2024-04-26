import SwiftUI
import EverythingButTheBagelCore
import Shimmer
import CatFactsCore

struct CatFactListItem: View {
  let vm: CatFactViewModel

  var body: some View {
    HStack {
      Text(vm.fact)
        .font(.body)
      Spacer()
    }
    .padding()
  }
}

extension CatFactListItem {
  static let loadingPlaceholder: some View = CatFactListItem(vm: .init(
    fact: "ffff Example of a long cat fact, Example of a long cat fact, Example of a long cat fact, Example of a long cat fact")
  )
  .redacted(reason: .placeholder)
  .shimmering()
  .accessibilityLabel("Loading")
}

#Preview {
  Group {
    CatFactListItem(vm: .init(fact: "Example of a long cat fact, Example of a long cat fact, Example of a long cat fact, Example of a long cat fact"))

    CatFactListItem.loadingPlaceholder
  }
}
