import SwiftCLI

enum Car: String, Validatable, ConvertibleFromString {
  case volvo, volkswagen, bmw, ferrari

  public enum ValidationOption: Validatorable {
    case isFast
    case isSwedish

    public func validate(element: Car) -> ValidationResult {
      switch (self, element) {
      case (.isFast, .ferrari):
        return .succeeded
      case (.isFast, _):
        return .failed("\(element) is not fast")
      case (.isSwedish, .volvo):
        return .succeeded
      case (.isSwedish, _):
        return .failed("\(element) is not Swedish")
      }
    }
  }
}
