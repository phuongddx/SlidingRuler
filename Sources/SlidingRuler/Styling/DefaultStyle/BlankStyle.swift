import SwiftUI

public struct BlankSlidingRulerStyle: SlidingRulerStyle {
  public let cursorAlignment: VerticalAlignment = .top

  public func makeCellBody(configuration: SlidingRulerStyleConfiguation) -> some FractionableView {
    BlankCellBody(mark: configuration.mark,
                  bounds: configuration.bounds,
                  step: configuration.step,
                  cellWidth: cellWidth)
  }

  public func makeCursorBody() -> some View {
    NativeCursorBody()
  }
}
