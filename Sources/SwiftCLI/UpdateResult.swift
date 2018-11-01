import Foundation

public enum UpdateResult: Equatable {
    case succeeded
    case illegalType
    case validationError(String)

    public static func == (lhs: UpdateResult, rhs: UpdateResult) -> Bool {
        switch (lhs, rhs) {
        case (.succeeded, .succeeded):
            return true
        case (.illegalType, .illegalType):
            return true
        case let (.validationError(msg1), .validationError(msg2)):
            return msg1 == msg2
        default:
            return false
        }
    }
}
