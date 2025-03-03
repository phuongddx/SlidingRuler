import SwiftUI

struct InfiniteMarkOffsetModifier: AnimatableModifier {
  @Environment(\.slidingRulerCellOverflow) private var overflow

  var value: CGFloat
  let step: CGFloat

  var offset: CGFloat {
    let overflow = CGFloat(overflow)
    return (value / step / overflow).approximated().rounded(.towardZero) * overflow
  }

  var animatableData: CGFloat {
    get { value }
    set { value = newValue }
  }

  init(_ value: CGFloat, step: CGFloat) {
    self.value = value
    self.step = step
  }

  func body(content: Content) -> some View {
    content.preference(key: MarkOffsetPreferenceKey.self, value: offset)
  }
}
