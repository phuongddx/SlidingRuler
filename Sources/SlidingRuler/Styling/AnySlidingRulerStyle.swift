import SwiftUI

public enum RulerDirection {
  case vertical
  case horizontal
}

struct AnySlidingRulerStyle: SlidingRulerStyle {
  private let cellProvider: (SlidingRulerStyleConfiguation) -> AnyFractionableView
  private let cursorProvider: () -> AnyView

  let fractions: Int
  let cellWidth: CGFloat
  let cursorAlignment: VerticalAlignment
  let hasMarks: Bool
  let direction: RulerDirection

  init(style: some SlidingRulerStyle) {
    cellProvider = { (configuration: SlidingRulerStyleConfiguation) -> AnyFractionableView in
      AnyFractionableView(style.makeCellBody(configuration: configuration))
    }
    cursorProvider = {
      AnyView(style.makeCursorBody())
    }
    fractions = style.fractions
    cellWidth = style.cellWidth
    cursorAlignment = style.cursorAlignment
    hasMarks = style.hasMarks
    direction = style.direction
  }

  func makeCellBody(configuration: SlidingRulerStyleConfiguation) -> some FractionableView {
    cellProvider(configuration)
  }

  func makeCursorBody() -> some View {
    cursorProvider()
  }
}
