import SwiftUI

enum StaticSlidingRulerStyleEnvironment {
  @Environment(\.slidingRulerStyle.cellWidth) static var cellWidth
  @Environment(\.slidingRulerStyle.cursorAlignment) static var alignment
  @Environment(\.slidingRulerStyle.hasMarks) static var hasMarks
}

struct SlidingRulerStyleEnvironmentKey: EnvironmentKey {
  static var defaultValue: AnySlidingRulerStyle {
    .init(style: VerticalSlidingRulerStyle())
  }

  static var horizontalStyle: AnySlidingRulerStyle {
    .init(style: PrimarySlidingRulerStyle())
  }

  static var verticalStyle: AnySlidingRulerStyle {
    .init(style: VerticalSlidingRulerStyle())
  }
}

struct SlideRulerCellOverflow: EnvironmentKey {
  static var defaultValue: Int { 1 }
}

extension EnvironmentValues {
  var slidingRulerStyle: AnySlidingRulerStyle {
    get { self[SlidingRulerStyleEnvironmentKey.self] }
    set { self[SlidingRulerStyleEnvironmentKey.self] = newValue }
  }

  var slidingRulerCellOverflow: Int {
    get { self[SlideRulerCellOverflow.self] }
    set { self[SlideRulerCellOverflow.self] = newValue }
  }
}
