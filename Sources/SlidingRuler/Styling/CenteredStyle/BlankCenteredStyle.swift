import SwiftUI

public struct BlankCenteredSlidingRulerStyle: SlidingRulerStyle {
  public let cursorAlignment: VerticalAlignment = .top

  public func makeCellBody(configuration: SlidingRulerStyleConfiguation) -> some FractionableView {
    BlankCenteredCellBody(mark: configuration.mark,
                          bounds: configuration.bounds,
                          step: configuration.step,
                          cellWidth: cellWidth)
  }

  public func makeCursorBody() -> some View {
    NativeCursorBody()
  }
}
