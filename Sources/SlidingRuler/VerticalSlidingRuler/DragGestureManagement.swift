import SwiftUI

// New: Vertical drag gesture value structure
struct VerticalDragGestureValue {
  let state: UIGestureRecognizer.State
  let translation: CGSize
  let velocity: CGFloat
  let startLocation: CGPoint
  let location: CGPoint
}

// New: Protocol for the view receiving vertical pan gestures
protocol VerticalPanGestureReceiverViewDelegate: AnyObject {
  func viewTouchedWithoutPan(_ view: UIView)
}

// New: View for receiving vertical pan gestures
class VerticalPanGestureReceiverView: UIView {
  weak var delegate: VerticalPanGestureReceiverViewDelegate?

  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesEnded(touches, with: event)
    delegate?.viewTouchedWithoutPan(self)
  }
}

// New: Extension to add vertical drag gesture to SwiftUI View
extension View {
  func onVerticalDragGesture(initialTouch: @escaping () -> Void = {},
                             prematureEnd: @escaping () -> Void = {},
                             perform action: @escaping (VerticalDragGestureValue) -> Void) -> some View
  {
    overlay(VerticalPanGesture(beginTouch: initialTouch, prematureEnd: prematureEnd, action: action))
  }
}

// New: UIViewRepresentable for vertical drag gesture
private struct VerticalPanGesture: UIViewRepresentable {
  typealias Action = (VerticalDragGestureValue) -> Void

  class Coordinator: NSObject, UIGestureRecognizerDelegate, VerticalPanGestureReceiverViewDelegate {
    private let beginTouch: () -> Void
    private let prematureEnd: () -> Void
    private let action: Action
    weak var view: UIView?

    init(_ beginTouch: @escaping () -> Void = {}, _ prematureEnd: @escaping () -> Void = {}, _ action: @escaping Action) {
      self.beginTouch = beginTouch
      self.prematureEnd = prematureEnd
      self.action = action
    }

    @objc func panGestureHandler(_ gesture: UIPanGestureRecognizer) {
      let translation = gesture.translation(in: view)
      let velocity = gesture.velocity(in: view)
      let location = gesture.location(in: view)
      let startLocation = location - translation

      let value = VerticalDragGestureValue(state: gesture.state,
                                           translation: .init(vertical: translation.y), // Use translation.y instead of x
                                           velocity: velocity.y, // Use velocity.y instead of x
                                           startLocation: startLocation,
                                           location: location)
      action(value)
    }

    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
      guard let pgr = gestureRecognizer as? UIPanGestureRecognizer else { return false }
      let velocity = pgr.velocity(in: view)
      return abs(velocity.y) > abs(velocity.x) // Check for vertical drag instead of horizontal
    }

    func gestureRecognizer(_: UIGestureRecognizer, shouldReceive _: UIEvent) -> Bool {
      beginTouch()
      return true
    }

    func viewTouchedWithoutPan(_: UIView) {
      prematureEnd()
    }
  }

  @Environment(\.slidingRulerStyle) private var style

  let beginTouch: () -> Void
  let prematureEnd: () -> Void
  let action: Action

  func makeCoordinator() -> Coordinator {
    .init(beginTouch, prematureEnd, action)
  }

  func makeUIView(context: Context) -> UIView {
    let view = VerticalPanGestureReceiverView(frame: .init(size: .init(square: 42)))
    let pgr = UIPanGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.panGestureHandler(_:)))
    view.delegate = context.coordinator
    pgr.delegate = context.coordinator
    view.addGestureRecognizer(pgr)
    context.coordinator.view = view

    // Pointer interactions
    if #available(iOS 13.4, *), style.supportsPointerInteraction {
      pgr.allowedScrollTypesMask = .continuous
      view.addInteraction(UIPointerInteraction(delegate: context.coordinator))
    }

    return view
  }

  func updateUIView(_: UIView, context _: Context) {}
}

@available(iOS 13.4, *)
extension VerticalPanGesture.Coordinator: UIPointerInteractionDelegate {
  func pointerInteraction(_: UIPointerInteraction, styleFor _: UIPointerRegion) -> UIPointerStyle? {
    .init(shape: .path(Pointers.standard), constrainedAxes: .horizontal) // Apply constrainedAxes for vertical
  }
}

// MARK: Drag Gesture Management

extension VerticalSlidingRuler {
  /// Callback handling first touch event.
  func firstTouchHappened() {
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

  /// Callback handling gesture premature ending.
  func panGestureEndedPrematurely() {
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

  /// Composite callback passed to the vertical drag gesture recognizer.
  func verticalDragAction(withValue value: VerticalDragGestureValue) {
    switch value.state {
    case .began: verticalDragBegan(value)
    case .changed: verticalDragChanged(value)
    case .ended: verticalDragEnded(value)
    default: return
    }
  }

  /// Callback handling vertical drag gesture beginning.
  func verticalDragBegan(_: VerticalDragGestureValue) {
    editingChangedCallback(true)
    if state != .stoppedSpring {
      dragOffset = offset(fromValue: clampedValue)
    }
    referenceOffset = dragOffset
    state = .dragging
  }

  /// Callback handling vertical drag gesture updating.
  func verticalDragChanged(_ value: VerticalDragGestureValue) {
    let newOffset = directionalOffset(value.translation.horizontal + referenceOffset)
    let newValue = self.value(fromOffset: newOffset)

    tickIfNeeded(dragOffset, newOffset)

    withoutAnimation {
      self.setValue(newValue)
      dragOffset = self.applyRubber(to: newOffset)
    }
  }

  /// Callback handling vertical drag gesture ending.
  func verticalDragEnded(_ value: VerticalDragGestureValue) {
    if isRubberBandNeedingRelease {
      releaseRubberBand()
      endDragSession()
    } else if abs(value.velocity) > 90 {
      applyInertia(initialVelocity: value.velocity)
    } else {
      state = .idle
      endDragSession()
      snapIfNeeded()
    }
  }

  /// Drag session clean-up.
  func endDragSession() {
    referenceOffset = .zero
    editingChangedCallback(false)
  }
}
