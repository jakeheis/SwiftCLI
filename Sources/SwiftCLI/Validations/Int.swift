extension Int: ConvertibleFromString {}

extension Int: Validatable {
  public typealias ValidationOption = NumericValidationOption<Int>
}
