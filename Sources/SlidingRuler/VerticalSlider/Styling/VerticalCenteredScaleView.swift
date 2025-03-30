//
//  CenteredScaleView.swift
//  SlidingRuler
//
//  Created by Phuong Doan Duy on 28/3/25.
//

import SwiftUI

struct VerticalCenteredScaleView: ScaleView {
    struct ScaleShape: Shape {
        fileprivate var defaultMarkSize = CGSize(width: 30, height: 1)
        fileprivate var unitMarkSize: CGSize { .init(width: 30, height: 2.5) }
        fileprivate var halfMarkSize: CGSize {
            defaultMarkSize
        }
        fileprivate var fractionMarkSize: CGSize {
            defaultMarkSize
        }

        func path(in rect: CGRect) -> Path {
            let centerY = rect.center.y
            var p = Path()
            
            // Unit mark at the center
            p.addRoundedRect(in: unitRect(y: centerY), cornerSize: .init(square: unitMarkSize.height / 2))
            
            // Half marks at the top and bottom
            p.addRoundedRect(in: halfRect(y: 0), cornerSize: .init(square: halfMarkSize.height / 2))
            p.addRoundedRect(in: halfRect(y: rect.maxY), cornerSize: .init(square: halfMarkSize.height / 2))
            
            // Fraction marks (1/10th divisions)
            let tenth = rect.height / 10
            for i in 1...4 {
                p.addRoundedRect(in: tenthRect(y: centerY + CGFloat(i) * tenth),
                                 cornerSize: .init(square: fractionMarkSize.height / 2))
                p.addRoundedRect(in: tenthRect(y: centerY - CGFloat(i) * tenth),
                                 cornerSize: .init(square: fractionMarkSize.height / 2))
            }
            
            return p
        }
        
        private func unitRect(y: CGFloat) -> CGRect {
            rect(centerY: y, size: unitMarkSize)
        }

        private func halfRect(y: CGFloat) -> CGRect {
            rect(centerY: y, size: halfMarkSize)
        }

        private func tenthRect(y: CGFloat) -> CGRect {
            rect(centerY: y, size: fractionMarkSize)
        }
        
        private func rect(centerY y: CGFloat, size: CGSize) -> CGRect {
            CGRect(origin: .init(x: 0, y: y - size.height / 2), size: size)
        }
    }

    let width: CGFloat
    let height: CGFloat
    var shape: ScaleShape { .init() }

    var unitMarkWidth: CGFloat { shape.unitMarkSize.width }
    var halfMarkWidth: CGFloat { shape.halfMarkSize.width }
    var fractionMarkWidth: CGFloat { shape.fractionMarkSize.width }

    init(width: CGFloat = 30,
         height: CGFloat = 100) {
        self.width = width
        self.height = height
    }
}

protocol VerticalNativeMarkedRulerCellView: VerticalMarkedRulerCellView { }

extension VerticalNativeMarkedRulerCellView {
    var markColor: Color {
        bounds.contains(mark) ? .init(.label) : .init(.tertiaryLabel)
    }
    var displayMark: String {
        numberFormatter?.string(for: mark) ?? "\(mark.approximated())" }

    var body: some View {
        HStack {
            Text(verbatim: displayMark)
                .font(Font.footnote.monospacedDigit())
                .foregroundColor(markColor)
                .lineLimit(1)
            cell
                .equatable()
        }
        .fixedSize()
    }
}

struct DefaultVerticalCenteredCellBody: VerticalNativeMarkedRulerCellView {
    var mark: CGFloat
    var bounds: ClosedRange<CGFloat>
    var step: CGFloat
    var cellHeight: CGFloat
    var numberFormatter: NumberFormatter?
    
    var cell: some VerticalRulerCellView {
        VerticalCenteredCellBody(
            mark: mark,
            bounds: bounds,
            step: step,
            cellHeight: cellHeight)
    }
}

struct VerticalCenteredCellBody: VerticalNativeRulerCellView {
    var mark: CGFloat
    var bounds: ClosedRange<CGFloat>
    var step: CGFloat
    var cellHeight: CGFloat
    
    var scale: some ScaleView {
        VerticalCenteredScaleView(height: cellHeight)
    }
}

public struct VerticalCenteredStyle: SlidingRulerStyle {
    public init(cursorAlignment: VerticalAlignment = .bottom,
                cellWidth: CGFloat = 80) {
        self.cursorAlignment = cursorAlignment
        self.cellWidth = cellWidth
    }
    
    public var cursorAlignment: VerticalAlignment
    public var cellWidth: CGFloat
    
    public func makeCellBody(configuration: SlidingRulerStyleConfiguation) -> some FractionableView {
        DefaultVerticalCenteredCellBody(mark: configuration.mark,
                                        bounds: configuration.bounds,
                                        step: configuration.step,
                                        cellHeight: cellWidth,
                                        numberFormatter: configuration.formatter)
    }
    
    public func makeCursorBody() -> some View {
        NativeCursorBody()
    }

    public struct NativeCursorBody: View {
        public var body: some View {
            Capsule()
                .foregroundColor(.red)
                .frame(
                    width: 30,
                    height: UIScreen.main.scale == 3 ? 1.8 : 2)
        }
    }
}

#Preview {
    VSlideRulerExample()
}

#Preview {
    HSlideRulerExample()
}
