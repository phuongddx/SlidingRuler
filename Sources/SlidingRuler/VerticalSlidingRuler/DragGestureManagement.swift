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

  /// Composite callback passed to the horizontal drag gesture recognizer.
  func horizontalDragAction(withValue value: HorizontalDragGestureValue) {
    switch value.state {
    case .began: horizontalDragBegan(value)
    case .changed: horizontalDragChanged(value)
    case .ended: horizontalDragEnded(value)
    default: return
    }
  }

  /// Callback handling horizontal drag gesture begining.
  func horizontalDragBegan(_: HorizontalDragGestureValue) {
    editingChangedCallback(true)
    if state != .stoppedSpring {
      dragOffset = offset(fromValue: clampedValue)
    }
    referenceOffset = dragOffset
    state = .dragging
  }

  /// Callback handling horizontal drag gesture updating.
  func horizontalDragChanged(_ value: HorizontalDragGestureValue) {
    let newOffset = directionalOffset(value.translation.horizontal + referenceOffset)
    let newValue = self.value(fromOffset: newOffset)

    tickIfNeeded(dragOffset, newOffset)

    withoutAnimation {
      self.setValue(newValue)
      dragOffset = self.applyRubber(to: newOffset)
    }
  }

  /// Callback handling horizontal drag gesture ending.
  func horizontalDragEnded(_ value: HorizontalDragGestureValue) {
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
