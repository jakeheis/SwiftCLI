// MARK: - ConvertibleFromString

/// A type that can be created from a string

public protocol ConvertibleFromString {
  /// Returns an instance of the conforming type from a string representation
  associatedtype ValidationOption: Validatorable = DefaultValidation<Self>

  static func convert(from: String) -> Self?
}
