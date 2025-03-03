extension ClosedRange {
  func contains(_ range: Self) -> Bool {
    contains(range.lowerBound) && contains(range.upperBound)
  }
}
