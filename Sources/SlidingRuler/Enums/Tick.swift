public enum Mark {
  case none, unit, half, fraction
}

public enum Tick {
  case none, unit, half, tenth

  var coeff: Double {
    switch self {
    case .none: .nan
    case .unit: 1
    case .half: 0.5
    case .tenth: 0.1
    }
  }
}
