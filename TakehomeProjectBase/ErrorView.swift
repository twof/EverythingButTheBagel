import SwiftUI
import TakehomeProjectBaseCore

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
            .lineLimit(1)
            .truncationMode(.tail)
            .padding([.top, .bottom], 20)
          
          Spacer()
          
        }
        .background {
          // TODO: Move color to assets
          Color.gray
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .padding([.leading, .trailing])
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
    .withError(vm: .init(id: "0", message: "Oh no! Something went wrong"))
    
}
