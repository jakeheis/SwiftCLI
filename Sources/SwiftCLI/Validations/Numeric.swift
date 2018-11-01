public enum NumericValidationOption<T: Numeric & Comparable>: Validatorable {
  case min(T)
  case max(T)
  case within(ClosedRange<T>)
  case positive

  public func validate(element: T) -> ValidationResult {
      switch self {
      case .positive where element <= 0:
         return .failed("Cannot be less then zero")
      case let .min(value) where value > element:
        return .failed("Must be larger then \(value)")
      case let .max(value) where value < element:
        return .failed("Must be smaller then \(value)")
      case let .within(range) where !range.contains(element):
        return .failed("Must be between \(range.lowerBound) and \(range.upperBound)")
      default:
        return .succeeded
      }
  }
}
