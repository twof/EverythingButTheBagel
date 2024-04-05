import SwiftUI
import EverythingButTheBagelCore
import Shimmer

struct CatFactListItem: View {
  let vm: CatFactViewModel

  var body: some View {
    HStack {
      Text(vm.fact)
      Spacer()
    }
    .padding()
  }
}

extension CatFactListItem {
  static let loadingPlaceholder: some View = CatFactListItem(vm: .init(
    fact: "Example of a long cat fact, Example of a long cat fact, Example of a long cat fact, Example of a long cat fact")
  )
  .redacted(reason: .placeholder)
  .shimmering()
}

#Preview {
  Group {
    CatFactListItem(vm: .init(fact: "Example of a long cat fact, Example of a long cat fact, Example of a long cat fact, Example of a long cat fact"))

    CatFactListItem(vm: .init(
      fact: "Example of a long cat fact, Example of a long cat fact, Example of a long cat fact, Example of a long cat fact")
    )
    .redacted(reason: .placeholder)
    .shimmering()
  }
}
