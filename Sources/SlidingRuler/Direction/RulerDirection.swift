//
//  RulerDirection.swift
//  SlidingRuler
//
//  Created by Phuong Doan Duy on 1/3/25.
//

import SwiftUI
import SmoothOperators

// MARK: - Ruler Direction
public enum RulerDirection {
    case horizontal
    case vertical
}

// MARK: - Horizontal Scale View
struct HorizontalScaleView: ScaleView {
    struct HorizontalScaleShape: Shape {
        fileprivate var unitMarkSize: CGSize { .init(width: 3.0, height: 27.0) }
        fileprivate var halfMarkSize: CGSize { .init(width: UIScreen.main.scale == 3 ? 1.8 : 2.0, height: 19.0) }
        fileprivate var fractionMarkSize: CGSize { .init(width: 1.0, height: 11.0) }
        
        func path(in rect: CGRect) -> Path {
            let centerX = rect.center.x
            var p = Path()
            
            p.addRoundedRect(in: unitRect(x: centerX), cornerSize: .init(square: unitMarkSize.width / 2))
            p.addRoundedRect(in: halfRect(x: 0), cornerSize: .init(square: halfMarkSize.width / 2))
            p.addRoundedRect(in: halfRect(x: rect.maxX), cornerSize: .init(square: halfMarkSize.width / 2))
            
            let tenth = rect.width / 10
            for i in 1...4 {
                p.addRoundedRect(in: tenthRect(x: centerX + CGFloat(i) * tenth), cornerSize: .init(square: fractionMarkSize.width / 2))
                p.addRoundedRect(in: tenthRect(x: centerX - CGFloat(i) * tenth), cornerSize: .init(square: fractionMarkSize.width / 2))
            }
            
            return p
        }
        
        private func unitRect(x: CGFloat) -> CGRect { rect(centerX: x, size: unitMarkSize) }
        private func halfRect(x: CGFloat) -> CGRect { rect(centerX: x, size: halfMarkSize) }
        private func tenthRect(x: CGFloat) -> CGRect { rect(centerX: x, size: fractionMarkSize) }
        
        private func rect(centerX x: CGFloat, size: CGSize) -> CGRect {
            CGRect(origin: .init(x: x - size.width / 2, y: 0), size: size)
        }
    }

    var shape: HorizontalScaleShape { .init() }
    let width: CGFloat
    let height: CGFloat

    var unitMarkWidth: CGFloat { shape.unitMarkSize.width }
    var halfMarkWidth: CGFloat { shape.halfMarkSize.width }
    var fractionMarkWidth: CGFloat { shape.fractionMarkSize.width }

    init(width: CGFloat, height: CGFloat = 30) {
        self.width = width
        self.height = height
    }
}

// MARK: - SlidingRuler
@available(iOS 13.0, *)
public struct SlidingRuler<V>: View where V: BinaryFloatingPoint, V.Stride: BinaryFloatingPoint {

    @Environment(\.slidingRulerCellOverflow) private var cellOverflow

    @Environment(\.slidingRulerStyle) private var style
    @Environment(\.slidingRulerStyle.cellWidth) private var cellWidth
    @Environment(\.slidingRulerStyle.cursorAlignment) private var cursorAlignment
    @Environment(\.slidingRulerStyle.fractions) private var fractions
    @Environment(\.slidingRulerStyle.hasHalf) private var hasHalf

    @Environment(\.layoutDirection) private var layoutDirection

    /// Bound value.
    @Binding private var controlValue: V
    /// Possible value range.
    private let bounds: ClosedRange<CGFloat>
    /// Value stride.
    private let step: CGFloat
    /// When to snap.
    private let snap: Mark
    /// When to tick.
    private let tick: Mark
    /// Edit changed callback.
    private let editingChangedCallback: (Bool) -> ()
    /// Number formatter for ruler's marks.
    private let formatter: NumberFormatter?
    /// Direction of the ruler.
    private let direction: RulerDirection

    /// Width of the control, retrieved through preference key.
    @State private var controlWidth: CGFloat?
    /// Height of the control, retrieved through preference key.
    @State private var controlHeight: CGFloat?

    /// Cells of the ruler.
    @State private var cells: [RulerCell] = [.init(CGFloat(0))]

    /// Control state.
    @State private var state: SlidingRulerState = .idle
    /// The reference offset set at the start of a drag session.
    @State private var referenceOffset: CGSize = .zero
    /// The virtual ruler's drag offset.
    @State private var dragOffset: CGSize = .zero
    /// Offset of the ruler's displayed marks.
    @State private var markOffset: CGFloat = .zero

    /// Non-bound value used for rubber release animation.
    @State private var animatedValue: CGFloat = .zero
    /// The last value the receiver did set.
    @State private var lastValueSet: CGFloat = .zero

    /// VSynch timer that drives animations.
    @State private var animationTimer: VSynchedTimer? = nil

    private var value: CGFloat {
        get { CGFloat(controlValue) ?? 0 }
        nonmutating set { controlValue = V(newValue) }
    }

    /// Allowed drag offset range.
    private var dragBounds: ClosedRange<CGFloat> {
        let lower = bounds.upperBound.isInfinite ? -CGFloat.infinity : -bounds.upperBound * cellWidth / step
        let upper = bounds.lowerBound.isInfinite ? CGFloat.infinity : -bounds.lowerBound * cellWidth / step
        return .init(uncheckedBounds: (lower, upper))
    }

    /// Amount of units the ruler can translate before needing to refresh cells.
    private var cellSizeOverflow: CGFloat { cellWidth * CGFloat(cellOverflow) }

    /// Current value clamped to the receiver's value bounds.
    private var clampedValue: CGFloat { value.clamped(to: bounds) }

    /// Ruler offset used to render the control depending on the state.
    private var effectiveOffset: CGSize {
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
    public init(value: Binding<V>,
                in bounds: ClosedRange<V> = -V.infinity...V.infinity,
                step: V.Stride = 1,
                snap: Mark = .none,
                tick: Mark = .none,
                direction: RulerDirection = .horizontal,
                onEditingChanged: @escaping (Bool) -> () = { _ in },
                formatter: NumberFormatter? = nil) {
        self._controlValue = value
        self.bounds = .init(uncheckedBounds: (CGFloat(bounds.lowerBound), CGFloat(bounds.upperBound)))
        self.step = CGFloat(step)
        self.snap = snap
        self.tick = tick
        self.direction = direction
        self.editingChangedCallback = onEditingChanged
        self.formatter = formatter
    }

    // MARK: Rendering
    
    public var body: some View {
        let (renderedValue, renderedOffset) = renderingValues()

        return FlexibleWidthContainer {
            ZStack(alignment: alignmentForDirection()) {
                RulerView(direction: direction, cells: self.cells, step: self.step, markOffset: self.markOffset, bounds: self.bounds, formatter: self.formatter)
                    .equatable()
                    .animation(nil)
                    .modifier(InfiniteOffsetEffect(offset: renderedOffset, maxOffset: self.cellSizeOverflow))
                self.style.makeCursorBody()
            }
        }
        .modifier(InfiniteMarkOffsetModifier(renderedValue, step: step))
        .propagateWidth(ControlWidthPreferenceKey.self)
        .propagateHeight(ControlHeightPreferenceKey.self)
        .onPreferenceChange(MarkOffsetPreferenceKey.self, storeValueIn: $markOffset)
        .onPreferenceChange(ControlWidthPreferenceKey.self, storeValueIn: $controlWidth) {
            if self.direction == .horizontal { self.updateCellsIfNeeded() }
        }
        .onPreferenceChange(ControlHeightPreferenceKey.self, storeValueIn: $controlHeight) {
            if self.direction == .vertical { self.updateCellsIfNeeded() }
        }
        .transaction {
            if $0.animation != nil { $0.animation = .easeIn(duration: 0.1) }
        }
        .onVerticalDragGesture(initialTouch: firstTouchHappened,
                               prematureEnd: panGestureEndedPrematurely,
                               perform: verticalDragAction(withValue:))
        .onHorizontalDragGesture(initialTouch: firstTouchHappened,
                                 prematureEnd: panGestureEndedPrematurely,
                                 perform: horizontalDragAction(withValue:))
    }

    private func renderingValues() -> (CGFloat, CGSize) {
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

    private func alignmentForDirection() -> Alignment {
        switch direction {
        case .horizontal:
            return .init(horizontal: .center, vertical: cursorAlignment)
        case .vertical:
            return .init(horizontal: cursorAlignment == .top ? .leading : cursorAlignment == .bottom ? .trailing : .center, vertical: .center)
        }
    }
}

// MARK: Gesture Management
extension SlidingRuler {
    @ViewBuilder
    private func applyGesture() -> some View {
        if direction == .horizontal {
            self.onHorizontalDragGesture(initialTouch: firstTouchHappened,
                                         prematureEnd: panGestureEndedPrematurely,
                                         perform: horizontalDragAction(withValue:))
        } else {
            self.onVerticalDragGesture(initialTouch: firstTouchHappened,
                                       prematureEnd: panGestureEndedPrematurely,
                                       perform: verticalDragAction(withValue:))
        }
    }

    private func firstTouchHappened() {
        switch state {
        case .flicking:
            cancelCurrentTimer()
            state = .stoppedFlick
        case .springing:
            cancelCurrentTimer()
            state = .stoppedSpring
        default: break
        }
    }

    private func panGestureEndedPrematurely() {
        switch state {
        case .stoppedFlick:
            state = .idle
            snapIfNeeded()
        case .stoppedSpring:
            releaseRubberBand()
        default:
            break
        }
    }

    private func horizontalDragAction(withValue value: HorizontalDragGestureValue) {
        switch value.state {
        case .began: horizontalDragBegan(value)
        case .changed: horizontalDragChanged(value)
        case .ended: horizontalDragEnded(value)
        default: return
        }
    }

    private func verticalDragAction(withValue value: VerticalDragGestureValue) {
        switch value.state {
        case .began: verticalDragBegan(value)
        case .changed: verticalDragChanged(value)
        case .ended: verticalDragEnded(value)
        default: return
        }
    }

    private func horizontalDragBegan(_ value: HorizontalDragGestureValue) {
        editingChangedCallback(true)
        if state != .stoppedSpring {
            dragOffset = self.offset(fromValue: clampedValue ?? 0)
        }
        referenceOffset = dragOffset
        state = .dragging
    }

    private func verticalDragBegan(_ value: VerticalDragGestureValue) {
        editingChangedCallback(true)
        if state != .stoppedSpring {
            dragOffset = self.offset(fromValue: clampedValue ?? 0)
        }
        referenceOffset = dragOffset
        state = .dragging
    }

    private func horizontalDragChanged(_ value: HorizontalDragGestureValue) {
        let newOffset = self.directionalOffset(value.translation.width + referenceOffset.width, 0)
        let newValue = self.value(fromOffset: newOffset)
        
        self.tickIfNeeded(dragOffset, newOffset)
        
        withoutAnimation {
            self.setValue(newValue)
            dragOffset = self.applyRubber(to: newOffset)
        }
    }

    private func verticalDragChanged(_ value: VerticalDragGestureValue) {
        let newOffset = self.directionalOffset(0, value.translation.height + referenceOffset.height)
        let newValue = self.value(fromOffset: newOffset)
        
        self.tickIfNeeded(dragOffset, newOffset)
        
        withoutAnimation {
            self.setValue(newValue)
            dragOffset = self.applyRubber(to: newOffset)
        }
    }

    private func horizontalDragEnded(_ value: HorizontalDragGestureValue) {
        if isRubberBandNeedingRelease {
            self.releaseRubberBand()
            self.endDragSession()
        } else if abs(value.velocity) > 90 {
            self.applyInertia(initialVelocity: value.velocity)
        } else {
            state = .idle
            self.endDragSession()
            self.snapIfNeeded()
        }
    }

    private func verticalDragEnded(_ value: VerticalDragGestureValue) {
        if isRubberBandNeedingRelease {
            self.releaseRubberBand()
            self.endDragSession()
        } else if abs(value.velocity) > 90 {
            self.applyInertia(initialVelocity: value.velocity)
        } else {
            state = .idle
            self.endDragSession()
            self.snapIfNeeded()
        }
    }

    private func endDragSession() {
        referenceOffset = .zero
        self.editingChangedCallback(false)
    }
}

// MARK: Value Management
extension SlidingRuler {
    private func value(fromOffset offset: CGSize) -> CGFloat {
        let offsetValue = direction == .horizontal ? offset.width : offset.height
        return self.directionalValue(-CGFloat(offsetValue / cellWidth) * step)
    }

    private func offset(fromValue value: CGFloat) -> CGSize {
        let offsetValue = -value * cellWidth / step
        return direction == .horizontal ?
            self.directionalOffset(offsetValue, 0) :
            self.directionalOffset(0, offsetValue)
    }

    private func setValue(_ newValue: CGFloat) {
        let clampedValue = newValue.clamped(to: bounds)
        
        if clampedValue.isBound(of: bounds) && !value.isBound(of: self.bounds) {
            self.boundaryMet()
        }
        
        if lastValueSet != clampedValue { lastValueSet = clampedValue }
        if value != clampedValue { value = clampedValue }
    }

    private func snapIfNeeded() {
        let nearest = self.nearestSnapValue(self.value)
        guard nearest != value else { return }

        let delta = abs(nearest - value)
        let fractionalValue = step / CGFloat(fractions)

        guard delta < fractionalValue else { return }

        let animThreshold = step / 200
        let animation: Animation? = delta > animThreshold ? .easeOut(duration: 0.1) : nil

        dragOffset = offset(fromValue: nearest)
        withAnimation(animation) { self.value = nearest }
    }

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

    func directionalValue<T: Numeric>(_ value: T) -> T {
        if direction == .horizontal {
            return value * (layoutDirection == .rightToLeft ? -1 : 1)
        } else {
            return value // No layout direction adjustment for vertical
        }
    }

    func directionalOffset(_ width: CGFloat, _ height: CGFloat) -> CGSize {
        if direction == .horizontal {
            let adjustedWidth = self.directionalValue(width)
            return .init(width: adjustedWidth, height: 0)
        } else {
            return .init(width: 0, height: height)
        }
    }
}

// MARK: Control Update
extension SlidingRuler {
    private func updateCellsIfNeeded() {
        let controlSize = direction == .horizontal ? controlWidth : controlHeight
        guard let controlSize = controlSize else { return }
        let count = (Int(ceil(controlSize / cellWidth)) + cellOverflow * 2).nextOdd()
        if count != cells.count { self.populateCells(count: count) }
    }

    private func populateCells(count: Int) {
        let boundary = count.previousEven() / 2
        cells = (-boundary...boundary).map { .init($0) }
    }
}

// MARK: Mechanic Simulation
extension SlidingRuler {
    private func applyInertia(initialVelocity: CGFloat) {
        func shiftOffset(by distance: CGSize) {
            let newOffset = directionalOffset(referenceOffset.width + distance.width, referenceOffset.height + distance.height)
            let newValue = self.value(fromOffset: newOffset)

            self.tickIfNeeded(self.dragOffset, newOffset)

            withoutAnimation {
                self.setValue(newValue)
                self.dragOffset = newOffset
            }
        }

        referenceOffset = dragOffset

        let rate = UIScrollView.DecelerationRate.ruler
        let totalDistance = Mechanic.Inertia.totalDistance(forVelocity: initialVelocity, decelerationRate: rate)
        let finalOffset = direction == .horizontal ?
            self.directionalOffset(referenceOffset.width + totalDistance, 0) :
            self.directionalOffset(0, referenceOffset.height + totalDistance)

        state = .flicking

        let finalOffsetValue = direction == .horizontal ? finalOffset.width : finalOffset.height
        let referenceOffsetValue = direction == .horizontal ? referenceOffset.width : referenceOffset.height

        if dragBounds.contains(finalOffsetValue) {
            let duration = Mechanic.Inertia.duration(forVelocity: initialVelocity, decelerationRate: rate)

            animationTimer = .init(duration: duration, animations: { (progress, interval) in
                let distanceValue = Mechanic.Inertia.distance(atTime: progress, v0: initialVelocity, decelerationRate: rate)
                let distance = self.directionalOffset(
                    self.direction == .horizontal ? distanceValue : 0,
                    self.direction == .vertical ? distanceValue : 0
                )
                shiftOffset(by: distance)
            }, completion: { (completed) in
                if completed {
                    self.state = .idle
                    let finalDistance = self.directionalOffset(
                        self.direction == .horizontal ? totalDistance : 0,
                        self.direction == .vertical ? totalDistance : 0
                    )
                    shiftOffset(by: finalDistance)
                    self.snapIfNeeded()
                    self.endDragSession()
                } else {
                    NextLoop { self.endDragSession() }
                }
            })
        } else {
            let allowedDistance = finalOffsetValue.clamped(to: dragBounds) - referenceOffsetValue
            let duration = Mechanic.Inertia.time(toReachDistance: allowedDistance, forVelocity: initialVelocity, decelerationRate: rate)
            animationTimer = .init(duration: duration, animations: { (progress, interval) in
                let distanceValue = Mechanic.Inertia.distance(atTime: progress, v0: initialVelocity, decelerationRate: rate)
                let distance = self.directionalOffset(
                    self.direction == .horizontal ? distanceValue : 0,
                    self.direction == .vertical ? distanceValue : 0
                )
                shiftOffset(by: distance)
            }, completion: { (completed) in
                if completed {
                    let finalDistance = self.directionalOffset(
                        self.direction == .horizontal ? allowedDistance : 0,
                        self.direction == .vertical ? allowedDistance : 0
                    )
                    shiftOffset(by: finalDistance)
                    let remainingVelocity = Mechanic.Inertia.velocity(atTime: duration, v0: initialVelocity, decelerationRate: rate)
                    self.applyInertialRubber(remainingVelocity: remainingVelocity)
                    self.endDragSession()
                } else {
                    NextLoop { self.endDragSession() }
                }
            })
        }
    }

    private func applyInertialRubber(remainingVelocity: CGFloat) {
        let duration = Mechanic.Spring.duration(forVelocity: abs(remainingVelocity), displacement: 0)
        let targetOffsetValue = (direction == .horizontal ? dragOffset.width : dragOffset.height).nearestBound(of: dragBounds)

        state = .springing

        animationTimer = .init(duration: duration, animations: { (progress, interval) in
            let delta = Mechanic.Spring.value(atTime: progress, v0: remainingVelocity, displacement: 0)
            self.dragOffset = self.directionalOffset(
                self.direction == .horizontal ? targetOffsetValue + delta : 0,
                self.direction == .vertical ? targetOffsetValue + delta : 0
            )
        }, completion: { (completed) in
            if completed {
                self.dragOffset = self.directionalOffset(
                    self.direction == .horizontal ? targetOffsetValue : 0,
                    self.direction == .vertical ? targetOffsetValue : 0
                )
                self.state = .idle
            }
        })
    }

    private func applyRubber(to offset: CGSize) -> CGSize {
        let offsetValue = direction == .horizontal ? offset.width : offset.height
        let dragBounds = self.dragBounds
        guard !dragBounds.contains(offsetValue) else { return offset }
        
        let limit = offsetValue.clamped(to: dragBounds)
        let delta = abs(offsetValue - limit)
        let factor: CGFloat = offsetValue - limit < 0 ? -1 : 1
        let controlDimension = direction == .horizontal ? (controlWidth ?? 0) : (controlHeight ?? 0)
        let c: CGFloat = 0.55
        let rubberDelta = (1 - (1 / ((c * delta / controlDimension) + 1))) * controlDimension * factor
        let rubberValue = limit + rubberDelta
        
        return direction == .horizontal ?
            .init(width: rubberValue, height: 0) :
            .init(width: 0, height: rubberValue)
    }

    private func releaseRubberBand() {
        let targetOffsetValue = (direction == .horizontal ? dragOffset.width : dragOffset.height).clamped(to: dragBounds)
        let delta = (direction == .horizontal ? dragOffset.width : dragOffset.height) - targetOffsetValue
        let duration = Mechanic.Spring.duration(forVelocity: 0, displacement: abs(delta))

        state = .springing

        animationTimer = .init(duration: duration, animations: { (progress, interval) in
            let newDelta = Mechanic.Spring.value(atTime: progress, v0: 0, displacement: delta)
            self.dragOffset = self.directionalOffset(
                self.direction == .horizontal ? targetOffsetValue + newDelta : 0,
                self.direction == .vertical ? targetOffsetValue + newDelta : 0
            )
        }, completion: { (completed) in
            if completed {
                self.dragOffset = self.directionalOffset(
                    self.direction == .horizontal ? targetOffsetValue : 0,
                    self.direction == .vertical ? targetOffsetValue : 0
                )
                self.state = .idle
            }
        })
    }

    private func cancelCurrentTimer() {
        animationTimer?.cancel()
        animationTimer = nil
    }
}

// MARK: Tick Management
extension SlidingRuler {
    private var isRubberBandNeedingRelease: Bool {
        let offsetValue = direction == .horizontal ? dragOffset.width : dragOffset.height
        return !dragBounds.contains(offsetValue)
    }

    private func boundaryMet() {
        let fg = UIImpactFeedbackGenerator(style: .rigid)
        fg.impactOccurred(intensity: 0.667)
    }

    private func tickIfNeeded(_ offset0: CGSize, _ offset1: CGSize) {
        let value0 = direction == .horizontal ? offset0.width : offset0.height
        let value1 = direction == .horizontal ? offset1.width : offset1.height

        let dragBounds = self.dragBounds
        guard dragBounds.contains(value0), dragBounds.contains(value1),
              !value0.isBound(of: dragBounds), !value1.isBound(of: dragBounds) else { return }
        
        let t: CGFloat
        switch tick {
        case .unit: t = cellWidth
        case .half: t = hasHalf ? cellWidth / 2 : cellWidth
        case .fraction: t = cellWidth / CGFloat(fractions)
        case .none: return
        }
        
        if value1 == 0 ||
           (value0 < 0) != (value1 < 0) ||
           Int((value0 / t).approximated()) != Int((value1 / t).approximated()) {
            valueTick()
        }
    }
    
    private func valueTick() {
        let fg = UIImpactFeedbackGenerator(style: .light)
        fg.impactOccurred(intensity: 0.5)
    }
}

// MARK: RulerView Helper
struct RulerView: View, Equatable {
  static func == (lhs: RulerView, rhs: RulerView) -> Bool {
    return true
  }

    let direction: RulerDirection
    let cells: [RulerCell]
    let step: CGFloat
    let markOffset: CGFloat
    let bounds: ClosedRange<CGFloat>
    let formatter: NumberFormatter?

    var body: some View {
        if direction == .horizontal {
            HStack(spacing: 0) {
                ForEach(cells) { cell in
                    HorizontalScaleView(width: 120, height: 30)
                }
            }
        } else {
            VStack(spacing: 0) {
                ForEach(cells) { cell in
                    VerticalScaleView(width: 30, height: 120)
                }
            }
        }
    }  
}

// MARK: Preference Key for Height
struct ControlHeightPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat? { nil }
    static func reduce(value: inout CGFloat?, nextValue: () -> CGFloat?) {
        value = nextValue() ?? value
    }
}

extension View {
    func propagateHeight(_ key: ControlHeightPreferenceKey.Type) -> some View {
        self.background(GeometryReader { proxy in
            Color.clear.preference(key: key, value: proxy.size.height)
        })
    }
}

// MARK: Extensions
extension UIScrollView.DecelerationRate {
    static var ruler: Self { Self.init(rawValue: 0.9972) }
}

extension CGRect {
    var center: CGPoint {
        .init(x: midX, y: midY)
    }
}

extension CGSize {
    init(square: CGFloat) {
        self.init(width: square, height: square)
    }

    init(horizontal: CGFloat) {
        self.init(width: horizontal, height: 0)
    }

    init(vertical: CGFloat) {
        self.init(width: 0, height: vertical)
    }
}

#Preview { ExampleRuler() }
