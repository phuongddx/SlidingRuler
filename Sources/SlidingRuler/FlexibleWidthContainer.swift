import SwiftUI

private struct _FlexibleWidthContainerHeightPreferenceKey: PreferenceKey {
  static func reduce(value: inout CGFloat?, nextValue: () -> CGFloat?) {
    if let newValue = nextValue() {
      value = newValue
    }
  }
}

struct FlexibleWidthContainer<Content: View>: View {
  @State private var height: CGFloat?
  private let content: Content

  init(@ViewBuilder content: @escaping () -> Content) {
    self.content = content()
  }

  var body: some View {
    Color.clear
      .frame(height: height)
      .overlay(content.propagateHeight(_FlexibleWidthContainerHeightPreferenceKey.self))
      .onPreferenceChange(_FlexibleWidthContainerHeightPreferenceKey.self, storeValueIn: $height)
      .clipped()
  }
}
