import Sprinkles
import EverythingButTheBagelCore
import CatFactsCore

extension LocalizedTextState {
  init(text: String) {
    self.init(text: text, stringCatalogLocation: .catFactsStringCatalog)
  }
}

extension LocalizedText {
  init(text: String) {
    self.init(LocalizedTextState(text: text))
  }
}
