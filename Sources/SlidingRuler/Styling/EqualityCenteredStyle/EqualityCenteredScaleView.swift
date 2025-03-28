//
//  EqualityCenteredScaleView.swift
//  SlidingRuler
//
//  Created by Phuong Doan Duy on 28/3/25.
//

import SwiftUI

struct EqualityCenteredScaleView: ScaleView {
    struct ScaleShape: Shape {
        fileprivate var defaultMarkSize = CGSize(width: 1, height: 30)
        fileprivate var unitMarkSize = CGSize(width: 2.5, height: 30)
        
        func path(in rect: CGRect) -> Path {
            let centerX: Double = rect.center.x
            var p = Path()
            
            p.addRoundedRect(in: unitRect(x: centerX, y: 0),
                             cornerSize: .init(square: unitMarkSize.width/2))
            
            p.addRoundedRect(in: halfRect(x: 0, y: 0),
                             cornerSize: .init(square: defaultMarkSize.width/2))
            
            p.addRoundedRect(in: halfRect(x: rect.maxX),
                             cornerSize: .init(square: defaultMarkSize.width/2))
            
            let tenth = rect.width / 10
            
            for i in 1...4 {
                p.addRoundedRect(in: tenthRect(x: centerX + CGFloat(i) * tenth),
                                 cornerSize: .init(square: defaultMarkSize.width/2))
                p.addRoundedRect(in: tenthRect(x: centerX - CGFloat(i) * tenth),
                                 cornerSize: .init(square: defaultMarkSize.width/2))
            }
            return p
        }
        
        private func unitRect(x: CGFloat, y: CGFloat = 0) -> CGRect {
            rect(centerX: x, y: y, size: unitMarkSize)
        }
        
        private func halfRect(x: CGFloat, y: CGFloat = 0) -> CGRect {
            rect(centerX: x, y: y, size: defaultMarkSize)
        }
        
        private func tenthRect(x: CGFloat, y: CGFloat = 0) -> CGRect {
            rect(centerX: x, y: y, size: defaultMarkSize)
        }
        
        private func rect(centerX x: CGFloat, size: CGSize) -> CGRect {
            CGRect(origin: .init(x: x - size.width / 2, y: 0), size: size)
        }
        
        private func rect(centerX x: CGFloat, y: CGFloat, size: CGSize) -> CGRect {
            CGRect(origin: .init(x: x - size.width / 2, y: y), size: size)
        }
    }
    
    var shape: ScaleShape { ScaleShape() }
    let width: CGFloat
    let height: CGFloat
    
    var unitMarkWidth: CGFloat {
        shape.defaultMarkSize.width }
    
    var halfMarkWidth: CGFloat {
        shape.defaultMarkSize.width }
    
    var fractionMarkWidth: CGFloat {
        shape.defaultMarkSize.width }
    
    init(width: CGFloat, height: CGFloat = 30) {
        self.width = width
        self.height = height
    }
}

struct DefaultEqualityCenteredCellBody: NativeMarkedRulerCellView {
    var mark: CGFloat
    var bounds: ClosedRange<CGFloat>
    var step: CGFloat
    var cellWidth: CGFloat
    var numberFormatter: NumberFormatter?
    
    var cell: some RulerCellView {
        EqualityCenteredCellBody(mark: mark, bounds: bounds, step: step, cellWidth: cellWidth)
    }
}

struct EqualityCenteredCellBody: NativeRulerCellView {
    var mark: CGFloat
    var bounds: ClosedRange<CGFloat>
    var step: CGFloat
    var cellWidth: CGFloat
    
    var scale: some ScaleView { EqualityCenteredScaleView(width: cellWidth) }
}

public struct EqualityCenteredStyle: SlidingRulerStyle {

    public init(cursorAlignment: VerticalAlignment = .bottom,
                cellWidth: CGFloat = 90) {
        self.cursorAlignment = cursorAlignment
        self.cellWidth = cellWidth
    }

    public var cursorAlignment: VerticalAlignment
    public var cellWidth: CGFloat

    public func makeCellBody(configuration: SlidingRulerStyleConfiguation) -> some FractionableView {
        DefaultEqualityCenteredCellBody(mark: configuration.mark,
                                        bounds: configuration.bounds,
                                        step: configuration.step,
                                        cellWidth: cellWidth,
                                        numberFormatter: configuration.formatter)
    }

    public func makeCursorBody() -> some View {
        NativeCursorBody()
    }
}

#Preview {
//    EqualityCenteredScaleView(width: 90)
    VSlideRulerExample()
}
