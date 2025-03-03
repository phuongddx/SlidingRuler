import SwiftUI

public protocol MarkedRulerCellView: FractionableView {
  associatedtype CellView: RulerCellView

  var mark: CGFloat { get }
  var bounds: ClosedRange<CGFloat> { get }
  var step: CGFloat { get }
  var cellWidth: CGFloat { get }

  var numberFormatter: NumberFormatter? { get }
  var markColor: Color { get }
  var cell: CellView { get }
}

extension MarkedRulerCellView {
  static var fractions: Int { CellView.fractions }
}
