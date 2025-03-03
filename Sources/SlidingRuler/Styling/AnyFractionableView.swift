import SwiftUI

struct AnyFractionableView: FractionableView {
  static var fractions: Int { 0 }
  private let view: AnyView
  var body: some View { view }
  init(_ view: some View) { self.view = AnyView(view) }
}
