import SwiftUI

public protocol RulerCellView: FractionableView, Equatable {
  associatedtype Scale: ScaleView
  associatedtype MaskShape: Shape

  var mark: CGFloat { get }
  var bounds: ClosedRange<CGFloat> { get }
  var cellBounds: ClosedRange<CGFloat> { get }
  var step: CGFloat { get }
  var cellWidth: CGFloat { get }

  var scale: Scale { get }
  var maskShape: MaskShape { get }
}

extension RulerCellView {
  static var fractions: Int { Scale.fractions }

  var cellBounds: ClosedRange<CGFloat> {
    ClosedRange(uncheckedBounds: (mark - step / 2, mark + step / 2))
  }

  var isComplete: Bool { bounds.contains(cellBounds) }

  var body: some View {
    ZStack {
      scale
        .equatable()
        .foregroundColor(.init(.label))
        .clipShape(maskShape)
      scale
        .equatable()
        .foregroundColor(.init(.tertiaryLabel))
    }
    .frame(width: cellWidth)
  }

  static func == (_ lhs: Self, _ rhs: Self) -> Bool {
    lhs.isComplete && rhs.isComplete
  }
}

#Preview {
  VerticalSlidingUsage()
}
