//
//  DragGestureManagement.swift
//  SlidingRuler
//
//  Created by Phuong Doan Duy on 2/3/25.
//


// MARK: Drag Gesture Management
extension VerticalSlidingRuler {
  
  /// Callback handling first touch event.
  internal func firstTouchHappened() {
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
  internal func panGestureEndedPrematurely() {
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
  
  /// Composite callback passed to the horizontal drag gesture recognizer.
  internal func horizontalDragAction(withValue value: HorizontalDragGestureValue) {
    switch value.state {
      case .began: horizontalDragBegan(value)
      case .changed: horizontalDragChanged(value)
      case .ended: horizontalDragEnded(value)
      default: return
    }
  }
  
  /// Callback handling horizontal drag gesture begining.
  internal func horizontalDragBegan(_ value: HorizontalDragGestureValue) {
    editingChangedCallback(true)
    if state != .stoppedSpring {
      dragOffset = self.offset(fromValue: clampedValue ?? 0)
    }
    referenceOffset = dragOffset
    state = .dragging
  }
  
  /// Callback handling horizontal drag gesture updating.
  internal func horizontalDragChanged(_ value: HorizontalDragGestureValue) {
    let newOffset = self.directionalOffset(value.translation.horizontal + referenceOffset)
    let newValue = self.value(fromOffset: newOffset)
    
    self.tickIfNeeded(dragOffset, newOffset)
    
    withoutAnimation {
      self.setValue(newValue)
      dragOffset = self.applyRubber(to: newOffset)
    }
  }
  
  /// Callback handling horizontal drag gesture ending.
  internal func horizontalDragEnded(_ value: HorizontalDragGestureValue) {
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
  
  /// Drag session clean-up.
  internal func endDragSession() {
    referenceOffset = .zero
    self.editingChangedCallback(false)
  }
}
