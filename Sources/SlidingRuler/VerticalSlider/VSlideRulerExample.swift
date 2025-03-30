//
//  VSlideRulerExample.swift
//  SlidingRuler
//
//  Created by Phuong Doan Duy on 27/3/25.
//

import SwiftUI

struct VSlideRulerExample: View {
    @State var value: Double = 14
    @Environment(\.slidingRulerStyle.cursorAlignment) var cursorAlignment

    let closedRange: ClosedRange<Double> = 11...17

    private var formatter: NumberFormatter {
        let formatter = NumberFormatter.init()
        formatter.numberStyle = .none
        return formatter
    }
    
    var body: some View {
        VStack {
            VSlidingRuler(value: $value,
                          in: closedRange,
                          step: 1,
                          snap: .none,
                          tick: .none,
                          formatter: formatter)
            .environment(\.slidingRulerStyle, AnySlidingRulerStyle(style: VerticalCenteredStyle()))
            .environment(\.slidingRulerCellOverflow, 1)
        }
    }
}

struct HSlideRulerExample: View {
    @State var value: Double = 15
    @Environment(\.slidingRulerStyle.cursorAlignment) var cursorAlignment
    
    let closedRange: ClosedRange<Double> = 1...10
    
    var body: some View {
        HStack {
            SlidingRuler(value: $value,
                          in: closedRange,
                          step: 1,
                          snap: .none,
                          tick: .none)
            .environment(\.slidingRulerCellOverflow, 1)
        }
    }
}

#Preview {
//    VSlideRulerExample()
    HSlideRulerExample()
}
