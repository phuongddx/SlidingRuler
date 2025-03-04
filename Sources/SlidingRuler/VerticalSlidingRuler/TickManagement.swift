import SmoothOperators
import SwiftUI

// MARK: Tick Management

extension VerticalSlidingRuler {
  func boundaryMet() {
    let fg = UIImpactFeedbackGenerator(style: .rigid)
    fg.impactOccurred(intensity: 0.667)
  }

  func tickIfNeeded(_ offset0: CGSize, _ offset1: CGSize) {
    let height0 = offset0.height, height1 = offset1.height

    let dragBounds = dragBounds
    guard dragBounds.contains(height0), dragBounds.contains(height1),
          !height0.isBound(of: dragBounds), !height1.isBound(of: dragBounds) else { return }

    let t: CGFloat
    switch tick {
    case .unit: t = cellWidth
    case .half: t = hasHalf ? cellWidth / 2 : cellWidth
    case .fraction: t = cellWidth / CGFloat(fractions)
    case .none: return
    }

    if height1 == 0 ||
      (height0 < 0) != (height1 < 0) ||
      Int((height0 / t).approximated()) != Int((height1 / t).approximated()) {
      valueTick()
    }
  }

  func valueTick() {
    let fg = UIImpactFeedbackGenerator(style: .light)
    fg.impactOccurred(intensity: 0.5)
  }
}

#Preview {
  VerticalSlidingUsage()
}
