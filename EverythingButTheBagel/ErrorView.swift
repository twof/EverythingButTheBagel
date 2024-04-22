import SwiftUI
import EverythingButTheBagelCore
import Sprinkles

struct ErrorView: ViewModifier {
  let vm: ErrorViewModel

  func body(content: Content) -> some View {
    ZStack {
      content
      VStack {
        Spacer()
        HStack {
          Image(systemName: "exclamationmark.circle")
            .padding(.leading)
            .bold()

          Text(vm.message)
            .foregroundStyle(Color.textPrimary)
            .padding([.top, .bottom], 20)

          Spacer()

        }
        .background {
          // TODO: Move color to assets
          Color.gray
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .padding([.leading, .trailing])
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Error")
        .accessibilityValue(vm.message)
      }
    }
  }
}

extension View {
  @ViewBuilder
  func withError(vm: ErrorViewModel?) -> some View {
    if let vm {
      modifier(ErrorView(vm: vm))
    } else {
      self
    }
  }
}

#Preview {
  Text("Hello")
    .withError(vm: .init(id: UUID(), message: "Oh no! Something went wrong"))
}
