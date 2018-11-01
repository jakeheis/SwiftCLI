// Default validations for types extending ConvertibleFromString

public enum DefaultValidation<T>: Validatorable {
  public func validate(element: T) -> ValidationResult {
    return .succeeded
  }
}
