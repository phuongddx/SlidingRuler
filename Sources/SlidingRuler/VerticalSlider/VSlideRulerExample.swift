//
//  VSlideRulerExample.swift
//  SlidingRuler
//
//  Created by Phuong Doan Duy on 27/3/25.
//

import SwiftUI

struct VSlideRulerExample: View {
    @State var value: Double = 11.5
    @Environment(\.slidingRulerStyle.cursorAlignment) var cursorAlignment

    let closedRange: ClosedRange<Double> = 11...17
    
    var body: some View {
        VSlidingRuler(value: $value,
                      in: closedRange,
                      step: 1,
                      snap: .none,
                      tick: .none)
        .environment(\.slidingRulerStyle, AnySlidingRulerStyle(style: EqualityCenteredStyle()))
    }
}

#Preview {
    VSlideRulerExample()
}
