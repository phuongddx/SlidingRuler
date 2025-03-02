import SmoothOperators
import SwiftUI

// MARK: Value Management

extension VerticalSlidingRuler {
  /// Compute the value from the given ruler's offset.
  func value(fromOffset offset: CGSize) -> CGFloat {
    directionalValue(-CGFloat(offset.width / cellWidth) * step)
  }

  /// Compute the ruler's offset from the given value.
  func offset(fromValue value: CGFloat) -> CGSize {
    let width = -value * cellWidth / step
    return directionalOffset(.init(horizontal: width))
  }

  /// Sets the value.
  func setValue(_ newValue: CGFloat) {
    let clampedValue = newValue.clamped(to: bounds)

    if clampedValue.isBound(of: bounds), !value.isBound(of: bounds) {
      boundaryMet()
    }

    if lastValueSet != clampedValue { lastValueSet = clampedValue }
    if value != clampedValue { value = clampedValue }
  }

  /// Snaps the value to the nearest mark based on the `snap` property.
  func snapIfNeeded() {
    let nearest = nearestSnapValue(value)
    guard nearest != value else { return }

    let delta = abs(nearest - value)
    let fractionalValue = step / CGFloat(fractions)

    guard delta < fractionalValue else { return }

    let animThreshold = step / 200
    let animation: Animation? = delta > animThreshold ? .easeOut(duration: 0.1) : nil

    dragOffset = offset(fromValue: nearest)
    withAnimation(animation) { self.value = nearest }
  }

  /// Returns the nearest value to snap on based on the `snap` property.
  private func nearestSnapValue(_ value: CGFloat) -> CGFloat {
    guard snap != .none else { return value }

    let t: CGFloat

    switch snap {
    case .unit: t = step
    case .half: t = step / 2
    case .fraction: t = step / CGFloat(fractions)
    default: fatalError()
    }

    let lower = (value / t).rounded(.down) * t
    let upper = (value / t).rounded(.up) * t
    let deltaDown = abs(value - lower).approximated()
    let deltaUp = abs(value - upper).approximated()

    return deltaDown < deltaUp ? lower : upper
  }

  ///  Transforms any numerical value based the layout direction. /!\ not properly tested.
  func directionalValue<T: Numeric>(_ value: T) -> T {
    value * (layoutDirection == .rightToLeft ? -1 : 1)
  }

  /// Transforms an offsetr based on the layout direction. /!\ not properly tested.
  func directionalOffset(_ offset: CGSize) -> CGSize {
    let width = directionalValue(offset.width)
    return .init(width: width, height: offset.height)
  }
}
