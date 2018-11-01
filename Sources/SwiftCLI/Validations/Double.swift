extension Double: ConvertibleFromString {}

extension Double: Validatable {
  public typealias ValidationOption = NumericValidationOption<Double>
}
