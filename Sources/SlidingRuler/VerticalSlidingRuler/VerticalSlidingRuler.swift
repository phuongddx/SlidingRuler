import SmoothOperators
import SwiftUI

public struct VerticalSlidingRuler<V>: View where V: BinaryFloatingPoint, V.Stride: BinaryFloatingPoint {
    @Environment(\.slidingRulerCellOverflow) var cellOverflow
    
    @Environment(\.slidingRulerStyle) var style
    @Environment(\.slidingRulerStyle.cellWidth) var cellWidth
    @Environment(\.slidingRulerStyle.cursorAlignment) var verticalCursorAlignment
    @Environment(\.slidingRulerStyle.fractions) var fractions
    @Environment(\.slidingRulerStyle.hasHalf) var hasHalf
    
    @Environment(\.layoutDirection) var layoutDirection
    
    /// Bound value.
    @Binding var controlValue: V
    /// Possible value range.
    let bounds: ClosedRange<CGFloat>
    /// Value stride.
    let step: CGFloat
    /// When to snap.
    let snap: Mark
    /// When to tick.
    let tick: Mark
    /// Edit changed callback.
    let editingChangedCallback: (Bool) -> Void
    /// Number formatter for ruler's marks.
    let formatter: NumberFormatter?
    
    /// Width of the control, retrieved through preference key.
    @State var controlWidth: CGFloat?
    /// Height of the ruller, retrieved through preference key.
    @State var rulerHeight: CGFloat?
    
    /// Cells of the ruler.
    @State var cells: [RulerCell] = [.init(CGFloat(0))]
    
    /// Control state.
    @State var state: SlidingRulerState = .idle
    /// The reference offset set at the start of a drag session.
    @State var referenceOffset: CGSize = .zero
    /// The virtual ruler's drag offset.
    @State var dragOffset: CGSize = .zero
    /// Offset of the ruler's displayed marks.
    @State var markOffset: CGFloat = .zero
    
    /// Non-bound value used for rubber release animation.
    @State var animatedValue: CGFloat = .zero
    /// The last value the receiver did set. Used to define if the rendered value was set by the receiver or from another component.
    @State var lastValueSet: CGFloat = .zero
    
    /// VSynch timer that drives animations.
    @State var animationTimer: VSynchedTimer? = nil
    
    var value: CGFloat {
        get { CGFloat(controlValue) ?? 0 }
        nonmutating set { controlValue = V(newValue) }
    }
    
    /// Allowed drag offset range.
    var dragBounds: ClosedRange<CGFloat> {
        let lower = bounds.upperBound.isInfinite ? -CGFloat.infinity : -bounds.upperBound * cellWidth / step
        let upper = bounds.lowerBound.isInfinite ? CGFloat.infinity : -bounds.lowerBound * cellWidth / step
        return .init(uncheckedBounds: (lower, upper))
    }
    
    /// Over-ranged drag rubber should be released.
    var isRubberBandNeedingRelease: Bool { !dragBounds.contains(dragOffset.width) }
    /// Amount of units the ruler can translate in both direction before needing to refresh the cells and reset offset.
    var cellWidthOverflow: CGFloat { cellWidth * CGFloat(cellOverflow) }
    /// Current value clamped to the receiver's value bounds.
    var clampedValue: CGFloat { value.clamped(to: bounds) }
    
    /// Ruler offset used to render the control depending on the state.
    var effectiveOffset: CGSize {
        switch state {
            case .idle:
                offset(fromValue: clampedValue ?? 0)
            case .animating:
                offset(fromValue: animatedValue ?? 0)
            default:
                dragOffset
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
                in bounds: ClosedRange<V> = -V.infinity ... V.infinity,
                step: V.Stride = 1,
                snap: Mark = .none,
                tick: Mark = .none,
                onEditingChanged: @escaping (Bool) -> Void = { _ in },
                formatter: NumberFormatter? = nil)
    {
      _controlValue = value
      self.bounds = .init(uncheckedBounds: (CGFloat(bounds.lowerBound), CGFloat(bounds.upperBound)))
      self.step = CGFloat(step)
      self.snap = snap
      self.tick = tick
      editingChangedCallback = onEditingChanged
      self.formatter = formatter
    }
    
    // MARK: Rendering
    
    public var body: some View {
        let renderedValue: CGFloat, renderedOffset: CGSize
        
        (renderedValue, renderedOffset) = renderingValues()
        
//        return FlexibleWidthContainer {
//            ZStack(alignment: .init(horizontal: .center,
//                                    vertical: .center)) {
//                HStack {
//                    VerticalRuler(cells: cells,
//                                  step: step,
//                                  markOffset: markOffset,
//                                  bounds: bounds,
//                                  formatter: formatter)
//                    .equatable()
//                    //          .modifier(InfiniteOffsetEffect(offset: renderedOffset, maxOffset: cellWidthOverflow))
//                    .modifier(VerticalInfiniteOffsetEffect(
//                        offset: renderedOffset, maxOffset: cellWidthOverflow
//                    ))
//                    style.makeCursorBody()
//                }
//            }
//        }
        return ZStack(alignment: .init(horizontal: .center,
                                       vertical: .center)) {
            ZStack {
                VerticalRuler(cells: cells,
                              step: step,
                              markOffset: markOffset,
                              bounds: bounds,
                              formatter: formatter)
                .equatable()
                .frame(height: CGFloat(cells.count) * cellWidth)
                .modifier(VerticalInfiniteOffsetEffect(
                    offset: renderedOffset,
                    maxOffset: cellWidthOverflow
                ))
                style.makeCursorBody()
            }
        }
        .modifier(InfiniteMarkOffsetModifier(renderedValue, step: step))
        .propagateHeight(ControlWidthPreferenceKey.self)
//        .propagateWidth(ControlWidthPreferenceKey.self)
        .onPreferenceChange(MarkOffsetPreferenceKey.self, storeValueIn: $markOffset)
        .onPreferenceChange(ControlWidthPreferenceKey.self, storeValueIn: $controlWidth) {
            updateCellsIfNeeded()
        }
//        .transaction {
//            if $0.animation != nil { $0.animation = .easeIn(duration: 0.1) }
//        }
//        .onVerticalDragGesture(initialTouch: firstTouchHappened,
//                               prematureEnd: panGestureEndedPrematurely,
//                               perform: verticalDragAction(withValue:))
    }
    
    func renderingValues() -> (CGFloat, CGSize) {
        let value: CGFloat
        let offset: CGSize
        
        switch state {
            case .flicking, .springing:
                if self.value != lastValueSet {
                    animationTimer?.cancel()
                    NextLoop { state = .idle }
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
                    NextLoop { state = .idle }
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
                                 in: 11 ... 17,
                                 step: 1,
                                 snap: .none,
                                 tick: .none)
            .frame(width: 200)
            .background(Color.gray.opacity(0.2))
            Text("\(value)")
        }
        .styleFor(rulerDirection: .vertical)
    }
}

struct HorizontalSlidingUsage: View {
    @State private var value: Double = 14
    var body: some View {
        VStack {
            SlidingRuler(value: $value,
                         in: 11 ... 17,
                         step: 1,
                         snap: .none,
                         tick: .none)
            .frame(width: 200)
            Text("\(value)")
        }
        .styleFor(rulerDirection: .horizontal)
    }
}

#Preview {
    HorizontalSlidingUsage()
}
