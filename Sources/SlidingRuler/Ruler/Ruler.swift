import SwiftUI

struct Ruler: View, Equatable {
  @Environment(\.slidingRulerStyle) private var style

  let cells: [RulerCell]
  let step: CGFloat
  let markOffset: CGFloat
  let bounds: ClosedRange<CGFloat>
  let formatter: NumberFormatter?

  var body: some View {
    HStack(spacing: 0) {
      ForEach(cells) { cell in
        style.makeCellBody(configuration: configuration(forCell: cell))
      }
    }
    .animation(nil)
  }

  private func configuration(forCell cell: RulerCell) -> SlidingRulerStyleConfiguation {
    .init(mark: (cell.mark + markOffset) * step, bounds: bounds, step: step, formatter: formatter)
  }

  static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.step == rhs.step &&
      lhs.cells.count == rhs.cells.count &&
      (!StaticSlidingRulerStyleEnvironment.hasMarks || lhs.markOffset == rhs.markOffset)
  }
}

struct Ruler_Previews: PreviewProvider {
  static var previews: some View {
    Ruler(cells: [.init(CGFloat(0))],
          step: 1.0, markOffset: 0, bounds: -1 ... 1, formatter: nil)
  }
}
