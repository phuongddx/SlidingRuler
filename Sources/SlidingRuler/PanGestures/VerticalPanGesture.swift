//
//  VerticalPanGesture.swift
//  SlidingRuler
//
//  Created by Phuong Doan Duy on 30/3/25.
//

import SwiftUI

struct VerticalPanGesture: UIViewRepresentable {
    typealias Action = (VerticalDragGestureValue) -> ()

    class Coordinator: NSObject, UIGestureRecognizerDelegate, PanGestureReceiverViewDelegate {
        private let beginTouch: () -> ()
        private let prematureEnd: () -> ()
        private let action: Action
        weak var view: UIView?
        
        init(_ beginTouch: @escaping () -> () = { },
             _ prematureEnd: @escaping () -> () = { },
             _ action: @escaping Action) {
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
            print("beginTouch")
            return true
        }
        
        func viewTouchedWithoutPan(_ view: UIView) {
            print("viewTouchedWithoutPan - prematureEnd")
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
        let view = PanGestureReceiverView(frame: .init(size: .init(square: 42)))
        let pgr = UIPanGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.panGestureHandler(_:)))
        view.delegate = context.coordinator
        pgr.delegate = context.coordinator
        view.addGestureRecognizer(pgr)
        context.coordinator.view = view
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) { }
}

#Preview { VSlideRulerExample() }
