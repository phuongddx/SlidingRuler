import SwiftUI

public struct VerticalSlidingRulerStyle: SlidingRulerStyle {
    public var cursorAlignment: VerticalAlignment = .top
    
    init(cursorAlignment: VerticalAlignment = .top) {
        self.cursorAlignment = cursorAlignment
    }
    
    public func makeCellBody(configuration: SlidingRulerStyleConfiguation) -> some FractionableView {
      VerticalCellBody(mark: configuration.mark,
                       bounds: configuration.bounds,
                       step: configuration.step,
                       cellWidth: cellWidth,
                       numberFormatter: configuration.formatter)
    }
    
    public func makeCursorBody() -> some View {
        NativeCursorBody(color: .red)
    }
}

#Preview {
    VerticalSlidingUsage()
}
