import SwiftUI

func NextLoop(_ perform: @escaping () -> Void) {
  DispatchQueue.main.async(execute: perform)
}

func withoutAnimation<Result>(_ body: () throws -> Result) rethrows -> Result {
  try withAnimation(nil, body)
}
