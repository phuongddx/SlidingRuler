import CoreGraphics

class RulerCell: Identifiable {
  var id: CGFloat { mark }
  var mark: CGFloat

  init(_ mark: Int) { self.mark = .init(mark) }
  init(_ mark: CGFloat) { self.mark = mark }
}
