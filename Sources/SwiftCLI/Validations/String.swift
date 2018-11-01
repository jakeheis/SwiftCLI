extension String: ConvertibleFromString {}

extension String: Validatable {
  public enum ValidationOption: Validatorable {
    case min(Int)
    case contains(String)

    public func validate(element: String) -> ValidationResult {
      switch self {
      case let .min(value) where value > element.count:
        return .failed("Must be larger then \(value)")
      case let .contains(value) where !element.contains(value):
        return .failed("Does not contain '\(value)'")
      default:
        return .succeeded
      }
    }
  }
}
