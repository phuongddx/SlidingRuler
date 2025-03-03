import Foundation

extension BinaryFloatingPoint {
  mutating func approximate() { self = approximated() }
  func approximated() -> Self { (self * 1_000_000).rounded() / 1_000_000 }

  func nearestBound(of range: ClosedRange<Self>, equality: Bool = false) -> Self {
    let deltaLow = self - range.lowerBound
    let deltaUp = range.upperBound - self

    if deltaUp == deltaLow {
      return !equality ? range.lowerBound : range.upperBound
    } else {
      return deltaLow < deltaUp ? range.lowerBound : range.upperBound
    }
  }
}
