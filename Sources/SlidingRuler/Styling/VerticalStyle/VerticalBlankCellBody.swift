//
//  VerticalBlankCellBody.swift
//  SlidingRuler
//
//  Created by Phuong Doan Duy on 7/3/25.
//

import SwiftUI

struct VerticalBlankCellBody: NativeRulerCellView {
    var mark: CGFloat
    var bounds: ClosedRange<CGFloat>
    var step: CGFloat
    var cellWidth: CGFloat

    var scale: some ScaleView {
        DefaultVerticalScaleView(height: 120)
    }
}

struct VerticalCellBody: VerticalNativeMarkedRulerCellView {
    var mark: CGFloat
    var bounds: ClosedRange<CGFloat>
    var step: CGFloat
    var cellWidth: CGFloat
    var numberFormatter: NumberFormatter?

    var cell: some RulerCellView {
        VerticalBlankCellBody(mark: mark, bounds: bounds, step: step, cellWidth: cellWidth)
    }
}
