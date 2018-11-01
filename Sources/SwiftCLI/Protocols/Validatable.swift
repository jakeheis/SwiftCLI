public protocol Validatable {
    associatedtype ValidationOption: Validatorable
        where ValidationOption.Element == Self
}
