//
//  VerticalDragGestureValue.swift
//  SlidingRuler
//
//  Created by Phuong Doan Duy on 1/3/25.
//

import SwiftUI
import CoreGeometry

struct VerticalDragGestureValue {
    let state: UIGestureRecognizer.State
    let translation: CGSize
    let velocity: CGFloat
    let startLocation: CGPoint
    let location: CGPoint
}

protocol VerticalPanGestureReceiverViewDelegate: AnyObject {
    func viewTouchedWithoutPan(_ view: UIView)
}

class VerticalPanGestureReceiverView: UIView {
    weak var delegate: VerticalPanGestureReceiverViewDelegate?

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        delegate?.viewTouchedWithoutPan(self)
    }
}

extension View {
    func onVerticalDragGesture(initialTouch: @escaping () -> () = { },
                               prematureEnd: @escaping () -> () = { },
                               perform action: @escaping (VerticalDragGestureValue) -> ()) -> some View {
        self.overlay(VerticalPanGesture(beginTouch: initialTouch, prematureEnd: prematureEnd, action: action))
    }
}

private struct VerticalPanGesture: UIViewRepresentable {
    typealias Action = (VerticalDragGestureValue) -> ()
    
    class Coordinator: NSObject, UIGestureRecognizerDelegate, VerticalPanGestureReceiverViewDelegate {
        private let beginTouch: () -> ()
        private let prematureEnd: () -> ()
        private let action: Action
        weak var view: UIView?
        
        init(_ beginTouch: @escaping () -> () = { }, _ prematureEnd: @escaping () -> () = { }, _ action: @escaping Action) {
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
                                                 translation: .init(vertical: translation.y),
                                                 velocity: velocity.y,
                                                 startLocation: startLocation,
                                                 location: location)
            self.action(value)
        }
        
        func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
            guard let pgr = gestureRecognizer as? UIPanGestureRecognizer else { return false }
            let velocity = pgr.velocity(in: view)
            return abs(velocity.y) > abs(velocity.x)
        }

        func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive event: UIEvent) -> Bool {
            beginTouch()
            return true
        }

        func viewTouchedWithoutPan(_ view: UIView) {
            prematureEnd()
        }
    }

    @Environment(\.slidingRulerStyle) private var style
    
    let beginTouch: () -> ()
    let prematureEnd: () -> ()
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
    
    func updateUIView(_ uiView: UIView, context: Context) { }
}

@available(iOS 13.4, *)
extension VerticalPanGesture.Coordinator: UIPointerInteractionDelegate {
    func pointerInteraction(_ interaction: UIPointerInteraction, styleFor region: UIPointerRegion) -> UIPointerStyle? {
        .init(shape: .path(Pointers.standard), constrainedAxes: .horizontal)
    }
}
