import SwiftUI

public protocol ScaleView: FractionableView, Equatable {
  associatedtype ScaleShape: Shape

  var shape: ScaleShape { get }
  var width: CGFloat { get }
  var height: CGFloat { get }

  var unitMarkWidth: CGFloat { get }
  var halfMarkWidth: CGFloat { get }
  var fractionMarkWidth: CGFloat { get }

  var unitMarkOffset: CGFloat { get }
  var halfMarkOffset: CGFloat { get }
  var fractionMarkOffset: CGFloat { get }
}

extension ScaleView {
  var body: some View {
    shape
      .frame(size: .init(width: width, height: height))
      .fixedSize()
      .background(Color.gray.opacity(0.2))
  }

  var unitMarkOffset: CGFloat { 0 }
  var halfMarkOffset: CGFloat { 0 }
  var fractionMarkOffset: CGFloat { 0 }

  static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.width == rhs.width && lhs.height == rhs.height
  }
}
