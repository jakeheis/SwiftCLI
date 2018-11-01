public protocol Validatorable {
    associatedtype Element
    func validate(element: Element) -> ValidationResult
}
