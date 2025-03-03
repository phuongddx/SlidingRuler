import SwiftUI

public struct PrimarySlidingRulerStyle: SlidingRulerStyle {
  public let cursorAlignment: VerticalAlignment = .top

  public func makeCellBody(configuration: SlidingRulerStyleConfiguation) -> some FractionableView {
    DefaultCellBody(mark: configuration.mark,
                    bounds: configuration.bounds,
                    step: configuration.step,
                    cellWidth: cellWidth,
                    numberFormatter: configuration.formatter)
  }

  public func makeCursorBody() -> some View {
    NativeCursorBody()
  }
}

struct DefaultStyle_Previews: PreviewProvider {
  struct CellTrio: View {
    let range: ClosedRange<CGFloat>
    let width: CGFloat

    var body: some View {
      HStack(spacing: 0) {
        BlankCellBody(mark: -1, bounds: range, step: 1, cellWidth: width).clipped()
        BlankCellBody(mark: 0, bounds: range, step: 1, cellWidth: width).clipped()
        BlankCellBody(mark: 1, bounds: range, step: 1, cellWidth: width).clipped()
      }
    }
  }

  static var previews: some View {
    CellTrio(range: 11 ... 17, width: 80)
      .previewLayout(.sizeThatFits)
    VerticalSlidingUsage()
  }
}
