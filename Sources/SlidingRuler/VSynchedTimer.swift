import UIKit

struct VSynchedTimer {
  typealias Animations = (TimeInterval, TimeInterval) -> Void
  typealias Completion = (Bool) -> Void

  private let timer: SynchedTimer

  init(duration: TimeInterval, animations: @escaping Animations, completion: Completion? = nil) {
    timer = .init(duration, animations, completion)
  }

  func cancel() { timer.cancel() }
}

private final class SynchedTimer {
  private let duration: TimeInterval
  private let animationBlock: VSynchedTimer.Animations
  private let completionBlock: VSynchedTimer.Completion?
  private weak var displayLink: CADisplayLink?

  private var isRunning: Bool
  private let startTimeStamp: TimeInterval
  private var lastTimeStamp: TimeInterval

  deinit {
    self.displayLink?.invalidate()
  }

  init(_ duration: TimeInterval, _ animations: @escaping VSynchedTimer.Animations, _ completion: VSynchedTimer.Completion? = nil) {
    self.duration = duration
    animationBlock = animations
    completionBlock = completion

    isRunning = true
    startTimeStamp = CACurrentMediaTime()
    lastTimeStamp = startTimeStamp
    displayLink = createDisplayLink()
  }

  func cancel() {
    guard isRunning else { return }

    isRunning.toggle()
    displayLink?.invalidate()
    completionBlock?(false)
  }

  private func complete() {
    guard isRunning else { return }

    isRunning.toggle()
    displayLink?.invalidate()
    completionBlock?(true)
  }

  @objc private func displayLinkTick(_: CADisplayLink) {
    guard isRunning else { return }

    let currentTimeStamp = CACurrentMediaTime()
    let progress = currentTimeStamp - startTimeStamp
    let elapsed = currentTimeStamp - lastTimeStamp
    lastTimeStamp = currentTimeStamp

    if progress < duration {
      animationBlock(progress, elapsed)
    } else {
      complete()
    }
  }

  private func createDisplayLink() -> CADisplayLink {
    let dl = CADisplayLink(target: self, selector: #selector(displayLinkTick(_:)))
    dl.add(to: .main, forMode: .common)

    return dl
  }
}
