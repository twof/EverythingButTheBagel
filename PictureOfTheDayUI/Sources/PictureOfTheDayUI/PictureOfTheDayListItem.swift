import SwiftUI
import Shimmer
import PictureOfTheDayCore
import UIKit

struct PictureOfTheDayListItem: View {
  let viewModel: PictureOfTheDayViewModel

  var body: some View {
    HStack(alignment: .top) {
      if let data = viewModel.thumbnailData, let image = UIImage(data: data) {
        Image(uiImage: image)
          .resizable()
          .frame(width: 100, height: 100)
          .aspectRatio(contentMode: .fit)
      } else {
        Rectangle()
          .foregroundStyle(Color.gray.opacity(0.7))
          .frame(width: 100, height: 100)
          .redacted(reason: .placeholder)
          .shimmering(bandSize: 10)
          .accessibilityLabel("Thumbnail Loading")
      }

      Text(viewModel.title)
        .font(.body)
      Spacer()
    }
    .padding()
  }
}

extension PictureOfTheDayListItem {
  static let loadingPlaceholder: some View = PictureOfTheDayListItem(
    viewModel: .init(
      title: "Example of a long cat fact, Example of a long cat fact,"
      + "Example of a long cat fact, Example of a long cat fact")
  )
    .redacted(reason: .placeholder)
    .shimmering()
    .accessibilityLabel("Loading")
}

#Preview {
  Group {
    PictureOfTheDayListItem(
      viewModel: .init(
        title: "Example of a long cat fact, Example of a"
        + "long cat fact, Example of a long cat fact, Example of a long cat fact"
      )
    )

    PictureOfTheDayListItem.loadingPlaceholder
  }
}
