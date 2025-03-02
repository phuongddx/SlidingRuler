//
//  MechanicSimulation.swift
//  SlidingRuler
//
//  Created by Phuong Doan Duy on 2/3/25.
//

import SwiftUI
import SmoothOperators

// MARK: Mechanic Simulation
extension VerticalSlidingRuler {
  
  internal func applyInertia(initialVelocity: CGFloat) {
    func shiftOffset(by distance: CGSize) {
      let newOffset = directionalOffset(self.referenceOffset + distance)
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
    let finalOffset = self.referenceOffset + .init(horizontal: totalDistance)
    
    state = .flicking
    
    if dragBounds.contains(finalOffset.width) {
      let duration = Mechanic.Inertia.duration(forVelocity: initialVelocity, decelerationRate: rate)
      
      animationTimer = .init(duration: duration, animations: { (progress, interval) in
        let distance =  CGSize(horizontal: Mechanic.Inertia.distance(atTime: progress, v0: initialVelocity, decelerationRate: rate))
        shiftOffset(by: distance)
      }, completion: { (completed) in
        if completed {
          self.state = .idle
          shiftOffset(by: .init(horizontal: totalDistance))
          self.snapIfNeeded()
          self.endDragSession()
        } else {
          NextLoop { self.endDragSession() }
        }
      })
    } else {
      let allowedDistance = finalOffset.width.clamped(to: dragBounds) - self.referenceOffset.width
      let duration = Mechanic.Inertia.time(toReachDistance: allowedDistance, forVelocity: initialVelocity, decelerationRate: rate)
      animationTimer = .init(duration: duration, animations: { (progress, interval) in
        let distance =  CGSize(horizontal: Mechanic.Inertia.distance(atTime: progress, v0: initialVelocity, decelerationRate: rate))
        shiftOffset(by: distance)
      }, completion: { (completed) in
        if completed {
          shiftOffset(by: .init(horizontal: allowedDistance))
          let remainingVelocity = Mechanic.Inertia.velocity(atTime: duration, v0: initialVelocity, decelerationRate: rate)
          self.applyInertialRubber(remainingVelocity: remainingVelocity)
          self.endDragSession()
        } else {
          NextLoop { self.endDragSession() }
        }
      })
    }
  }
  
  internal func applyInertialRubber(remainingVelocity: CGFloat) {
    let duration = Mechanic.Spring.duration(forVelocity: abs(remainingVelocity), displacement: 0)
    let targetOffset = dragOffset.width.nearestBound(of: dragBounds)
    
    state = .springing
    
    animationTimer = .init(duration: duration, animations: { (progress, interval) in
      let delta = Mechanic.Spring.value(atTime: progress, v0: remainingVelocity, displacement: 0)
      self.dragOffset = .init(horizontal: targetOffset + delta)
    }, completion: { (completed) in
      if completed {
        self.dragOffset = .init(horizontal: targetOffset)
        self.state = .idle
      }
    })
  }
  
  /// Applies rubber effect to an off-range offset.
  internal func applyRubber(to offset: CGSize) -> CGSize {
    let dragBounds = self.dragBounds
    guard !dragBounds.contains(offset.width) else { return offset }
    
    let tx = offset.width
    let limit = tx.clamped(to: dragBounds)
    let delta = abs(tx - limit)
    let factor: CGFloat = tx - limit < 0 ? -1 : 1
    let d = controlWidth ?? 0
    let c = CGFloat(0.55)
    let rubberDelta = (1 - (1 / ((c * delta / d) + 1))) * d * factor
    let rubberTx = limit + rubberDelta
    
    return .init(horizontal: rubberTx)
  }
  
  /// Animates an off-range offset back in place
  internal func releaseRubberBand() {
    let targetOffset = dragOffset.width.clamped(to: dragBounds)
    let delta = dragOffset.width - targetOffset
    let duration = Mechanic.Spring.duration(forVelocity: 0, displacement: abs(delta))
    
    state = .springing
    
    animationTimer = .init(duration: duration, animations: { (progress, interval) in
      let newDelta = Mechanic.Spring.value(atTime: progress, v0: 0, displacement: delta)
      self.dragOffset = .init(horizontal: targetOffset + newDelta)
    }, completion: { (completed) in
      if completed {
        self.dragOffset = .init(horizontal: targetOffset)
        self.state = .idle
      }
    })
  }
  
  /// Stops the current animation and cleans the timer.
  internal func cancelCurrentTimer() {
    animationTimer?.cancel()
    animationTimer = nil
  }
  
  internal func cleanTimer() {
    animationTimer = nil
  }
}
