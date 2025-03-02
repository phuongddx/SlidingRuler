//
//  VerticalSlidingRuler.swift
//  VerticalSlidingRuler
//
//  Created by Phuong Doan Duy on 2/3/25.
//

import SwiftUI
import SmoothOperators

public struct VerticalSlidingRuler<V>: View where V: BinaryFloatingPoint, V.Stride: BinaryFloatingPoint {
  
  @Environment(\.slidingRulerCellOverflow) internal var cellOverflow
  
  @Environment(\.slidingRulerStyle) internal var style
  @Environment(\.slidingRulerStyle.cellWidth) internal var cellWidth
  @Environment(\.slidingRulerStyle.cursorAlignment) internal var verticalCursorAlignment
  @Environment(\.slidingRulerStyle.fractions) internal var fractions
  @Environment(\.slidingRulerStyle.hasHalf) internal var hasHalf
  
  @Environment(\.layoutDirection) internal var layoutDirection
  
  /// Bound value.
  @Binding internal var controlValue: V
  /// Possible value range.
  internal let bounds: ClosedRange<CGFloat>
  /// Value stride.
  internal let step: CGFloat
  /// When to snap.
  internal let snap: Mark
  /// When to tick.
  internal let tick: Mark
  /// Edit changed callback.
  internal let editingChangedCallback: (Bool) -> ()
  /// Number formatter for ruler's marks.
  internal let formatter: NumberFormatter?
  
  /// Width of the control, retrieved through preference key.
  @State internal var controlWidth: CGFloat?
  /// Height of the ruller, retrieved through preference key.
  @State internal var rulerHeight: CGFloat?
  
  /// Cells of the ruler.
  @State internal var cells: [RulerCell] = [.init(CGFloat(0))]
  
  /// Control state.
  @State internal var state: SlidingRulerState = .idle
  /// The reference offset set at the start of a drag session.
  @State internal var referenceOffset: CGSize = .zero
  /// The virtual ruler's drag offset.
  @State internal var dragOffset: CGSize = .zero
  /// Offset of the ruler's displayed marks.
  @State internal var markOffset: CGFloat = .zero
  
  /// Non-bound value used for rubber release animation.
  @State internal var animatedValue: CGFloat = .zero
  /// The last value the receiver did set. Used to define if the rendered value was set by the receiver or from another component.
  @State internal var lastValueSet: CGFloat = .zero
  
  /// VSynch timer that drives animations.
  @State internal var animationTimer: VSynchedTimer? = nil
  
  internal var value: CGFloat {
    get { CGFloat(controlValue) ?? 0 }
    nonmutating set { controlValue = V(newValue) }
  }
  
  /// Allowed drag offset range.
  internal var dragBounds: ClosedRange<CGFloat> {
    let lower = bounds.upperBound.isInfinite ? -CGFloat.infinity : -bounds.upperBound * cellWidth / step
    let upper = bounds.lowerBound.isInfinite ? CGFloat.infinity : -bounds.lowerBound * cellWidth / step
    return .init(uncheckedBounds: (lower, upper))
  }
  
  /// Over-ranged drag rubber should be released.
  internal var isRubberBandNeedingRelease: Bool { !dragBounds.contains(dragOffset.width) }
  /// Amount of units the ruler can translate in both direction before needing to refresh the cells and reset offset.
  internal var cellWidthOverflow: CGFloat { cellWidth * CGFloat(cellOverflow) }
  /// Current value clamped to the receiver's value bounds.
  internal var clampedValue: CGFloat { value.clamped(to: bounds) }
  
  /// Ruler offset used to render the control depending on the state.
  internal var effectiveOffset: CGSize {
    switch state {
      case .idle:
        return self.offset(fromValue: clampedValue ?? 0)
      case .animating:
        return self.offset(fromValue: animatedValue ?? 0)
      default:
        return dragOffset
    }
  }
  
  /// Creates a SlidingRuler
  /// - Parameters:
  ///   - value: A binding connected to the control value.
  ///   - bounds: A closed range of possible values. Defaults to `-V.infinity...V.infinity`.
  ///   - step: The stride of the SlidingRuler. Defaults to `1`.
  ///   - snap: The ruler's marks stickyness. Defaults to `.none`
  ///   - tick: The graduation type that produce an haptic feedback when reached. Defaults to `.none`
  ///   - onEditingChanged: A closure executed when a drag session happens. It receives a boolean value set to `true` when the drag session starts and `false` when the value stops changing. Defaults to no action.
  ///   - formatter: A `NumberFormatter` instance the ruler uses to format the ruler's marks. Defaults to `nil`.
  public init(value: Binding<V>,
              in bounds: ClosedRange<V> = -V.infinity...V.infinity,
              step: V.Stride = 1,
              snap: Mark = .none,
              tick: Mark = .none,
              onEditingChanged: @escaping (Bool) -> () = { _ in },
              formatter: NumberFormatter? = nil) {
    self._controlValue = value
    self.bounds = .init(uncheckedBounds: (CGFloat(bounds.lowerBound), CGFloat(bounds.upperBound)))
    self.step = CGFloat(step)
    self.snap = snap
    self.tick = tick
    self.editingChangedCallback = onEditingChanged
    self.formatter = formatter
  }
  
  // MARK: Rendering
  
  public var body: some View {
    let renderedValue: CGFloat, renderedOffset: CGSize
    
    (renderedValue, renderedOffset) = renderingValues()
    
    return FlexibleWidthContainer {
      ZStack(alignment: .init(horizontal: .center, vertical: self.verticalCursorAlignment)) {
        Ruler(cells: self.cells, step: self.step, markOffset: self.markOffset, bounds: self.bounds, formatter: self.formatter)
          .equatable()
          .animation(nil)
          .modifier(InfiniteOffsetEffect(offset: renderedOffset, maxOffset: self.cellWidthOverflow))
        self.style.makeCursorBody()
      }
    }
    .modifier(InfiniteMarkOffsetModifier(renderedValue, step: step))
    .propagateWidth(ControlWidthPreferenceKey.self)
    .onPreferenceChange(MarkOffsetPreferenceKey.self, storeValueIn: $markOffset)
    .onPreferenceChange(ControlWidthPreferenceKey.self, storeValueIn: $controlWidth) {
      self.updateCellsIfNeeded()
    }
    .transaction {
      if $0.animation != nil { $0.animation = .easeIn(duration: 0.1) }
    }
    .onHorizontalDragGesture(initialTouch: firstTouchHappened,
                             prematureEnd: panGestureEndedPrematurely,
                             perform: horizontalDragAction(withValue:))
  }
  
  internal func renderingValues() -> (CGFloat, CGSize) {
    let value: CGFloat
    let offset: CGSize
    
    switch self.state {
      case .flicking, .springing:
        if self.value != self.lastValueSet {
          self.animationTimer?.cancel()
          NextLoop { self.state = .idle }
          value = clampedValue ?? 0
          offset = self.offset(fromValue: value)
        } else {
          fallthrough
        }
      case .dragging, .stoppedFlick, .stoppedSpring:
        offset = dragOffset
        value = self.value(fromOffset: offset)
      case .animating:
        if self.value != lastValueSet {
          NextLoop { self.state = .idle }
          fallthrough
        }
        value = animatedValue
        offset = self.offset(fromValue: value)
      case .idle:
        value = clampedValue ?? 0
        offset = self.offset(fromValue: value)
    }
    
    return (value, offset)
  }
}

struct VerticalSlidingUsage: View {
  @State private var value: Double = .zero
  
  var body: some View {
    VStack {
      VerticalSlidingRuler(value: $value,
                           in: 11...17,
                           step: 1,
                           snap: .none,
                           tick: .none)
      Text("\(value)")
    }
  }
}

#Preview {
  VerticalSlidingUsage()
}

