import SwiftUI

struct CenteredScaleView: ScaleView {
  struct ScaleShape: Shape {
    fileprivate var unitMarkSize: CGSize { .init(width: 3.0, height: 27.0) }
    fileprivate var halfMarkSize: CGSize { .init(width: UIScreen.main.scale == 3 ? 1.8 : 2.0, height: 19.0) }
    fileprivate var fractionMarkSize: CGSize { .init(width: 1.0, height: 11.0) }

    func path(in rect: CGRect) -> Path {
      let centerX = rect.center.x
      let centerY = rect.center.y
      var p = Path()

      p.addRoundedRect(in: unitRect(x: centerX, y: centerY), cornerSize: .init(square: unitMarkSize.width / 2))
      p.addRoundedRect(in: halfRect(x: 0, y: centerY), cornerSize: .init(square: halfMarkSize.width / 2))
      p.addRoundedRect(in: halfRect(x: rect.maxX, y: centerY), cornerSize: .init(square: halfMarkSize.width / 2))

      let tenth = rect.width / 10
      for i in 1 ... 4 {
        p.addRoundedRect(in: tenthRect(x: centerX + CGFloat(i) * tenth, y: centerY), cornerSize: .init(square: fractionMarkSize.width / 2))
        p.addRoundedRect(in: tenthRect(x: centerX - CGFloat(i) * tenth, y: centerY), cornerSize: .init(square: fractionMarkSize.width / 2))
      }

      return p
    }

    private func unitRect(x: CGFloat, y: CGFloat) -> CGRect { .init(center: .init(x: x, y: y), size: unitMarkSize) }
    private func halfRect(x: CGFloat, y: CGFloat) -> CGRect { .init(center: .init(x: x, y: y), size: halfMarkSize) }
    private func tenthRect(x: CGFloat, y: CGFloat) -> CGRect { .init(center: .init(x: x, y: y), size: fractionMarkSize) }
  }

  let width: CGFloat
  let height: CGFloat
  var shape: ScaleShape { .init() }

  var unitMarkWidth: CGFloat { shape.unitMarkSize.width }
  var halfMarkWidth: CGFloat { shape.halfMarkSize.width }
  var fractionMarkWidth: CGFloat { shape.fractionMarkSize.width }

  init(width: CGFloat, height: CGFloat = 30) {
    self.width = width
    self.height = height
  }
}
