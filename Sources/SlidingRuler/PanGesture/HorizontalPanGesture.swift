import CoreGeometry
import SwiftUI

struct HorizontalDragGestureValue {
  let state: UIGestureRecognizer.State
  let translation: CGSize
  let velocity: CGFloat
  let startLocation: CGPoint
  let location: CGPoint
}

protocol HorizontalPanGestureReceiverViewDelegate: AnyObject {
  func viewTouchedWithoutPan(_ view: UIView)
}

class HorizontalPanGestureReceiverView: UIView {
  weak var delegate: HorizontalPanGestureReceiverViewDelegate?

  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesEnded(touches, with: event)
    delegate?.viewTouchedWithoutPan(self)
  }
}

extension View {
  func onHorizontalDragGesture(initialTouch: @escaping () -> Void = {},
                               prematureEnd: @escaping () -> Void = {},
                               perform action: @escaping (HorizontalDragGestureValue) -> Void) -> some View
  {
    overlay(HorizontalPanGesture(beginTouch: initialTouch, prematureEnd: prematureEnd, action: action))
  }
}

private struct HorizontalPanGesture: UIViewRepresentable {
  typealias Action = (HorizontalDragGestureValue) -> Void

  class Coordinator: NSObject, UIGestureRecognizerDelegate, HorizontalPanGestureReceiverViewDelegate {
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

      let value = HorizontalDragGestureValue(state: gesture.state,
                                             translation: .init(horizontal: translation.x),
                                             velocity: velocity.x,
                                             startLocation: startLocation,
                                             location: location)
      action(value)
    }

    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
      guard let pgr = gestureRecognizer as? UIPanGestureRecognizer else { return false }
      let velocity = pgr.velocity(in: view)
      return abs(velocity.x) > abs(velocity.y)
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
    let view = HorizontalPanGestureReceiverView(frame: .init(size: .init(square: 42)))
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

extension HorizontalPanGesture.Coordinator: UIPointerInteractionDelegate {
  func pointerInteraction(_: UIPointerInteraction, styleFor _: UIPointerRegion) -> UIPointerStyle? {
    .init(shape: .path(Pointers.standard), constrainedAxes: .vertical)
  }
}
