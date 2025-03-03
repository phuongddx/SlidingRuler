import SwiftUI

struct ControlWidthPreferenceKey: PreferenceKey {
  static var defaultValue: CGFloat?
  static func reduce(value: inout CGFloat?, nextValue: () -> CGFloat?) {
    if let newValue = nextValue() { value = newValue }
  }
}

struct MarkOffsetPreferenceKey: PreferenceKey {
  static var defaultValue: CGFloat = .zero
  static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
    value = nextValue()
  }
}
