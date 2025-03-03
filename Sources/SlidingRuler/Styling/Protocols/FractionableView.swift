import SwiftUI

public protocol FractionableView: View {
  static var fractions: Int { get }
  static var hasHalf: Bool { get }
}

extension FractionableView {
  static var fractions: Int { 10 }
  static var hasHalf: Bool { fractions.isEven }
}
