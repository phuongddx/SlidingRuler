//
//  File.swift
//  SlidingRuler
//
//  Created by Phuong Doan Duy on 2/3/25.
//

import SmoothOperators
import SwiftUI

// MARK: Control Update
extension VerticalSlidingRuler {
  
  /// Adjusts the number of cells as the control size changes.
  internal func updateCellsIfNeeded() {
    guard let controlWidth = controlWidth else { return }
    let count = (Int(ceil(controlWidth / cellWidth)) + cellOverflow * 2).nextOdd()
    if count != cells.count { self.populateCells(count: count) }
  }
  
  /// Creates `count` cells for the ruler.
  internal func populateCells(count: Int) {
    let boundary = count.previousEven() / 2
    cells = (-boundary...boundary).map { .init($0) }
  }
}
