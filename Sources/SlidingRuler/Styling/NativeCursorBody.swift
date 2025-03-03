import SwiftUI

public struct NativeCursorBody: View {
  @Environment(\.slidingRulerStyle) private var style

  let color: Color
  var width: CGFloat {
    style.direction == .horizontal ? 3 : 30
  }

  var height: CGFloat {
    style.direction == .vertical ? 3 : 30
  }

  init(color: Color = .green) {
    self.color = color
  }

  public var body: some View {
    Capsule()
      .foregroundColor(color)
      .frame(width: width, height: height)
  }
}

struct CursorBody_Previews: PreviewProvider {
  static var previews: some View {
    NativeCursorBody()
  }
}
