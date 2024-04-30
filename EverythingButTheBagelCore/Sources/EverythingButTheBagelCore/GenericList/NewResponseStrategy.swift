/// Tells the underlying view model to append new items to its list or reset the list
public enum NewResponseStrategy: Equatable {
  case reset
  case append
}
