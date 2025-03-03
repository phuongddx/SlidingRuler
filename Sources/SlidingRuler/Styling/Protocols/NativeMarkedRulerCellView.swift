import SwiftUI

protocol NativeMarkedRulerCellView: MarkedRulerCellView {}

extension NativeMarkedRulerCellView {
  var markColor: Color {
    bounds.contains(mark) ? .init(.label) : .init(.tertiaryLabel)
  }

  var displayMark: String { numberFormatter?.string(for: mark) ?? "\(mark.approximated())" }

  var body: some View {
    VStack {
      cell.equatable()
      Spacer()
      Text(verbatim: displayMark)
        .font(Font.footnote.monospacedDigit())
        .foregroundColor(markColor)
        .lineLimit(1)
    }
    .fixedSize()
  }
}

protocol VerticalNativeMarkedRulerCellView: MarkedRulerCellView {}
extension VerticalNativeMarkedRulerCellView {
  var markColor: Color {
    bounds.contains(mark) ? .init(.label) : .init(.tertiaryLabel)
  }

  var displayMark: String { numberFormatter?.string(for: mark) ?? "\(mark.approximated())" }

  var body: some View {
    HStack(spacing: 0) {
      cell.equatable()
      Text(verbatim: displayMark)
        .font(Font.footnote.monospacedDigit())
        .foregroundColor(markColor)
        .lineLimit(1)
    }
    .fixedSize()
  }
}
