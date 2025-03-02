//
//  VerticalInfiniteOffsetEffect.swift
//  SlidingRuler
//
//  Created by Phuong Doan Duy on 2/3/25.
//

import SwiftUI

struct VerticalInfiniteOffsetEffect: GeometryEffect {
  var offset: CGSize
  let maxOffset: CGFloat
  
  var correctedOffset: CGSize {
    let ty = offset.height.truncatingRemainder(dividingBy: maxOffset)
    return .init(vertical: ty)
  }
  
  var animatableData: CGSize.AnimatableData {
    get { offset.animatableData }
    set { offset.animatableData = newValue }
  }
  
  func effectValue(size: CGSize) -> ProjectionTransform {
    assert(!size.width.isNaN && !size.height.isNaN)
    return ProjectionTransform(CGAffineTransform(translationX: 0, y: correctedOffset.height))
  }
}
