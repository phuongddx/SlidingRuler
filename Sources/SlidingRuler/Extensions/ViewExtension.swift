import SwiftUI

public extension View {
  func slidingRulerStyle(_ style: some SlidingRulerStyle) -> some View {
    environment(\.slidingRulerStyle, .init(style: style))
  }

  func slidingRulerCellOverflow(_ overflow: Int) -> some View {
    environment(\.slidingRulerCellOverflow, overflow)
  }
}

extension View {
  func frame(size: CGSize?, alignment: Alignment = .center) -> some View {
    frame(width: size?.width, height: size?.height, alignment: alignment)
  }

  func onPreferenceChange<K: PreferenceKey>(_ key: K.Type,
                                            storeValueIn storage: Binding<K.Value>,
                                            action: (() -> Void)? = nil) -> some View where K.Value: Equatable
  {
    onPreferenceChange(key, perform: {
      storage.wrappedValue = $0
      action?()
    })
  }

  func propagateHeight<K: PreferenceKey>(_ key: K.Type, transform: @escaping (K.Value) -> K.Value = { $0 }) -> some View where K.Value == CGFloat? {
    overlay(
      GeometryReader { proxy in
        Color.clear
          .preference(key: key, value: transform(proxy.size.height))
      }
    )
  }

  func propagateWidth<K: PreferenceKey>(_ key: K.Type, transform: @escaping (K.Value) -> K.Value = { $0 }) -> some View where K.Value == CGFloat? {
    overlay(
      GeometryReader { proxy in
        Color.clear
          .preference(key: key, value: transform(proxy.size.width))
      }
    )
  }
}

#Preview { HorizontalSlidingUsage() }
