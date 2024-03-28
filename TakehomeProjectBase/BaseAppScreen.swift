import SwiftUI
import TakehomeProjectBaseCore
import ComposableArchitecture

/// Containter view that holds content, but displayes global information like errors
/// and connection status
struct BaseAppScreen: View {
  let store: StoreOf<AppReducer>
  
  var body: some View {
    /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Hello, world!@*/Text("Hello, world!")/*@END_MENU_TOKEN@*/
  }
}
