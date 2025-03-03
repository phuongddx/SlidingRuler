import Foundation

extension Comparable {
  static func clamp(_ x: Self, _ min: Self, _ max: Self) -> Self {
    Swift.min(Swift.max(x, min), max)
  }

  func clamped(to min: Self, _ max: Self) -> Self {
    Self.clamp(self, min, max)
  }

  mutating func clamp(to min: Self, _ max: Self) {
    self = Self.clamp(self, min, max)
  }

  func clamped(to range: ClosedRange<Self>) -> Self {
    Self.clamp(self, range.lowerBound, range.upperBound)
  }

  mutating func clamp(to range: ClosedRange<Self>) {
    self = clamped(to: range)
  }

  func isBound(of range: ClosedRange<Self>) -> Bool {
    range.lowerBound == self || range.upperBound == self
  }
}
