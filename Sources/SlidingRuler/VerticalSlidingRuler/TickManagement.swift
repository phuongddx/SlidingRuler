//
//  TickManagement.swift
//  SlidingRuler
//
//  Created by Phuong Doan Duy on 2/3/25.
//

import SwiftUI
import SmoothOperators

// MARK: Tick Management
extension VerticalSlidingRuler {
  internal func boundaryMet() {
    let fg = UIImpactFeedbackGenerator(style: .rigid)
    fg.impactOccurred(intensity: 0.667)
  }
  
  internal func tickIfNeeded(_ offset0: CGSize, _ offset1: CGSize) {
    let width0 = offset0.width, width1 = offset1.width
    
    let dragBounds = self.dragBounds
    guard dragBounds.contains(width0), dragBounds.contains(width1),
          !width0.isBound(of: dragBounds), !width1.isBound(of: dragBounds) else { return }
    
    let t: CGFloat
    switch tick {
      case .unit: t = cellWidth
      case .half: t = hasHalf ? cellWidth / 2 : cellWidth
      case .fraction: t = cellWidth / CGFloat(fractions)
      case .none: return
    }
    
    if width1 == 0 ||
        (width0 < 0) != (width1 < 0) ||
        Int((width0 / t).approximated()) != Int((width1 / t).approximated()) {
      valueTick()
    }
  }
  
  internal func valueTick() {
    let fg = UIImpactFeedbackGenerator(style: .light)
    fg.impactOccurred(intensity: 0.5)
  }
}
