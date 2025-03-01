//
//  VerticalScaleView.swift
//  SlidingRuler
//
//  Created by Phuong Doan Duy on 1/3/25.
//

import SwiftUI

struct DefaultVerticalScaleView: ScaleView {
    struct VerticalScaleShape: Shape {
        fileprivate var unitMarkSize: CGSize { .init(width: 27.0, height: 3.0) } // Swapped width/height for vertical
        fileprivate var halfMarkSize: CGSize { .init(width: 19.0, height: UIScreen.main.scale == 3 ? 1.8 : 2.0) }
        fileprivate var fractionMarkSize: CGSize { .init(width: 11.0, height: 1.0) }
        
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
                p.addRoundedRect(in: tenthRect(y: centerY + CGFloat(i) * tenth), cornerSize: .init(square: fractionMarkSize.height / 2))
                p.addRoundedRect(in: tenthRect(y: centerY - CGFloat(i) * tenth), cornerSize: .init(square: fractionMarkSize.height / 2))
            }
            
            return p
        }
        
        private func unitRect(y: CGFloat) -> CGRect { rect(centerY: y, size: unitMarkSize) }
        private func halfRect(y: CGFloat) -> CGRect { rect(centerY: y, size: halfMarkSize) }
        private func tenthRect(y: CGFloat) -> CGRect { rect(centerY: y, size: fractionMarkSize) }
        
        private func rect(centerY y: CGFloat, size: CGSize) -> CGRect {
            CGRect(origin: .init(x: 0, y: y - size.height / 2), size: size)
        }
    }

    var shape: VerticalScaleShape { .init() }
    let width: CGFloat
    let height: CGFloat

    var unitMarkWidth: CGFloat { shape.unitMarkSize.height }
    var halfMarkWidth: CGFloat { shape.halfMarkSize.height }
    var fractionMarkWidth: CGFloat { shape.fractionMarkSize.height }

    init(width: CGFloat = 30, height: CGFloat) {
        self.width = width
        self.height = height
    }
}

struct VerticalScaleView_Previews: PreviewProvider {
  static var previews: some View {
    Group {
      DefaultVerticalScaleView(height: 120)
    }
    .previewLayout(.sizeThatFits)
  }
}
