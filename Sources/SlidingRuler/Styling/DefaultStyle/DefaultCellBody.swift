import SwiftUI

struct BlankCellBody: NativeRulerCellView {
  var mark: CGFloat
  var bounds: ClosedRange<CGFloat>
  var step: CGFloat
  var cellWidth: CGFloat

  var scale: some ScaleView { DefaultScaleView(width: cellWidth) }
}

struct DefaultCellBody: NativeMarkedRulerCellView {
  var mark: CGFloat
  var bounds: ClosedRange<CGFloat>
  var step: CGFloat
  var cellWidth: CGFloat
  var numberFormatter: NumberFormatter?

  var cell: some RulerCellView {
    BlankCellBody(mark: mark, bounds: bounds, step: step, cellWidth: cellWidth)
  }
}