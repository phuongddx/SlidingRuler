import SwiftUI

public protocol SlidingRulerStyle {
  associatedtype CellBody: FractionableView
  associatedtype CursorBody: View

  var fractions: Int { get }
  var cellWidth: CGFloat { get }
  var cursorAlignment: VerticalAlignment { get }
  var hasMarks: Bool { get }
  var hasHalf: Bool { get }
  var supportsPointerInteraction: Bool { get }
  var direction: RulerDirection { get }

  func makeCellBody(configuration: SlidingRulerStyleConfiguation) -> CellBody
  func makeCursorBody() -> CursorBody
}

public extension SlidingRulerStyle {
  var fractions: Int { CellBody.fractions }
  var cellWidth: CGFloat { 120 }
  var hasMarks: Bool { true }
  var hasHalf: Bool { CellBody.hasHalf }
  var supportsPointerInteraction: Bool { true }
  var direction: RulerDirection { .vertical }
}
