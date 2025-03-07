import SwiftUI

public struct CenteredSlindingRulerStyle: SlidingRulerStyle {
  public var cursorAlignment: VerticalAlignment = .top

  public func makeCellBody(configuration: SlidingRulerStyleConfiguation) -> some FractionableView {
    CenteredCellBody(mark: configuration.mark,
                     bounds: configuration.bounds,
                     step: configuration.step,
                     cellWidth: cellWidth,
                     numberFormatter: configuration.formatter)
  }

  public func makeCursorBody() -> some View {
      NativeCursorBody()
  }
}
