import SwiftUI

struct DefaultScaleView: ScaleView {
  struct ScaleShape: Shape {
    fileprivate var unitMarkSize: CGSize { .init(width: 3.0, height: 27.0) }
    fileprivate var halfMarkSize: CGSize { .init(width: UIScreen.main.scale == 3 ? 1.8 : 2.0, height: 19.0) }
    fileprivate var fractionMarkSize: CGSize { .init(width: 1.0, height: 11.0) }

    func path(in rect: CGRect) -> Path {
      let centerX = rect.center.x
      var p = Path()

      p.addRoundedRect(in: unitRect(x: centerX), cornerSize: .init(square: unitMarkSize.width / 2))
      p.addRoundedRect(in: halfRect(x: 0), cornerSize: .init(square: halfMarkSize.width / 2))
      p.addRoundedRect(in: halfRect(x: rect.maxX), cornerSize: .init(square: halfMarkSize.width / 2))

      let tenth = rect.width / 10
      for i in 1 ... 4 {
        p.addRoundedRect(in: tenthRect(x: centerX + CGFloat(i) * tenth), cornerSize: .init(square: fractionMarkSize.width / 2))
        p.addRoundedRect(in: tenthRect(x: centerX - CGFloat(i) * tenth), cornerSize: .init(square: fractionMarkSize.width / 2))
      }

      return p
    }

    private func unitRect(x: CGFloat) -> CGRect { rect(centerX: x, size: unitMarkSize) }
    private func halfRect(x: CGFloat) -> CGRect { rect(centerX: x, size: halfMarkSize) }
    private func tenthRect(x: CGFloat) -> CGRect { rect(centerX: x, size: fractionMarkSize) }

    private func rect(centerX x: CGFloat, size: CGSize) -> CGRect {
      CGRect(origin: .init(x: x - size.width / 2, y: 0), size: size)
    }
  }

  var shape: ScaleShape { .init() }
  let width: CGFloat
  let height: CGFloat

  var unitMarkWidth: CGFloat { shape.unitMarkSize.width }
  var halfMarkWidth: CGFloat { shape.halfMarkSize.width }
  var fractionMarkWidth: CGFloat { shape.fractionMarkSize.width }

  init(width: CGFloat, height: CGFloat = 30) {
    self.width = width
    self.height = height
  }
}

struct ScaleView_Previews: PreviewProvider {
  static var previews: some View {
    Group {
      DefaultScaleView(width: 120)
    }
    .previewLayout(.sizeThatFits)
  }
}
