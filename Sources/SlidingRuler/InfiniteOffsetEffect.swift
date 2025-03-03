import SwiftUI

struct InfiniteOffsetEffect: GeometryEffect {
  var offset: CGSize
  let maxOffset: CGFloat

  var correctedOffset: CGSize {
    let tx = offset.width.truncatingRemainder(dividingBy: maxOffset)
    return .init(horizontal: tx)
  }

  var animatableData: CGSize.AnimatableData {
    get { offset.animatableData }
    set { offset.animatableData = newValue }
  }

  func effectValue(size: CGSize) -> ProjectionTransform {
    assert(!size.width.isNaN && !size.height.isNaN)
    return ProjectionTransform(CGAffineTransform(translationX: correctedOffset.width, y: correctedOffset.height))
  }
}
