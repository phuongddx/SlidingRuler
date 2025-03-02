import SmoothOperators
import SwiftUI

// MARK: Control Update

extension VerticalSlidingRuler {
  /// Adjusts the number of cells as the control size changes.
  func updateCellsIfNeeded() {
    guard let controlWidth else { return }
    let count = (Int(ceil(controlWidth / cellWidth)) + cellOverflow * 2).nextOdd()
    if count != cells.count { populateCells(count: count) }
  }

  /// Creates `count` cells for the ruler.
  func populateCells(count: Int) {
    let boundary = count.previousEven() / 2
    cells = (-boundary ... boundary).map { .init($0) }
  }
}
