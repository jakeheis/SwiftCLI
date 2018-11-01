extension Float: ConvertibleFromString {}

extension Float: Validatable {
  public typealias ValidationOption = NumericValidationOption<Float>
}
