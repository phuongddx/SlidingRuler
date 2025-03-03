import SwiftUI

struct BlankCenteredCellBody: NativeRulerCellView {
  var mark: CGFloat
  var bounds: ClosedRange<CGFloat>
  var step: CGFloat
  var cellWidth: CGFloat

  var scale: some ScaleView { CenteredScaleView(width: cellWidth) }
}

struct CenteredCellBody: NativeMarkedRulerCellView {
  var mark: CGFloat
  var bounds: ClosedRange<CGFloat>
  var step: CGFloat
  var cellWidth: CGFloat
  var numberFormatter: NumberFormatter?

  var cell: some RulerCellView { BlankCenteredCellBody(mark: mark, bounds: bounds, step: step, cellWidth: cellWidth) }
}
