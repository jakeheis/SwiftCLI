/// Result
///
/// Container for a successful value (T) or a failure with an NSError
///

import Foundation

/// A success `Result` returning `value`
/// This form is preferred to `Result.Success(Box(value))` because it
// does not require dealing with `Box()`
public func success<T,E>(value: T) -> Result<T,E> {
  return .Success(Box(value))
}

/// A failure `Result` returning `error`
/// The default error is an empty one so that `failure()` is legal
/// To assign this to a variable, you must explicitly give a type.
/// Otherwise the compiler has no idea what `T` is. This form is preferred
/// to Result.Failure(error) because it provides a useful default.
/// For example:
///    let fail: Result<Int> = failure()
///

/// Dictionary keys for default errors
public let ErrorFileKey = "LMErrorFile"
public let ErrorLineKey = "LMErrorLine"

private func defaultError(userInfo: [NSObject: AnyObject]) -> NSError {
  return NSError(domain: "", code: 0, userInfo: userInfo)
}

private func defaultError(message: String, file: String = __FILE__, line: Int = __LINE__) -> NSError {
  return defaultError([NSLocalizedDescriptionKey: message, ErrorFileKey: file, ErrorLineKey: line])
}

private func defaultError(file: String = __FILE__, line: Int = __LINE__) -> NSError {
  return defaultError([ErrorFileKey: file, ErrorLineKey: line])
}

public func failure<T>(message: String, file: String = __FILE__, line: Int = __LINE__) -> Result<T,NSError> {
  let userInfo: [NSObject : AnyObject] = [NSLocalizedDescriptionKey: message, ErrorFileKey: file, ErrorLineKey: line]
  return failure(defaultError(userInfo))
}

public func failure<T>(file: String = __FILE__, line: Int = __LINE__) -> Result<T,NSError> {
  let userInfo: [NSObject : AnyObject] = [ErrorFileKey: file, ErrorLineKey: line]
  return failure(defaultError(userInfo))
}

public func failure<T,E>(error: E) -> Result<T,E> {
  return .Failure(Box(error))
}

/// Construct a `Result` using a block which receives an error parameter.
/// Expected to return non-nil for success.

public func try<T>(f: NSErrorPointer -> T?, file: String = __FILE__, line: Int = __LINE__) -> Result<T,NSError> {
  var error: NSError?
  return f(&error).map(success) ?? failure(error ?? defaultError(file: file, line: line))
}

public func try(f: NSErrorPointer -> Bool, file: String = __FILE__, line: Int = __LINE__) -> Result<(),NSError> {
  var error: NSError?
  return f(&error) ? success(()) : failure(error ?? defaultError(file: file, line: line))
}

/// Container for a successful value (T) or a failure with an E
public enum Result<T,E> {
  case Success(Box<T>)
  case Failure(Box<E>)

  /// The successful value as an Optional
  public var value: T? {
    switch self {
    case .Success(let box): return box.unbox
    case .Failure: return nil
    }
  }

  /// The failing error as an Optional
  public var error: E? {
    switch self {
    case .Success: return nil
    case .Failure(let err): return err.unbox
    }
  }

  public var isSuccess: Bool {
    switch self {
    case .Success: return true
    case .Failure: return false
    }
  }

  /// Return a new result after applying a transformation to a successful value.
  /// Mapping a failure returns a new failure without evaluating the transform
  public func map<U>(transform: T -> U) -> Result<U,E> {
    switch self {
    case Success(let box):
      return .Success(Box(transform(box.unbox)))
    case Failure(let err):
      return .Failure(err)
    }
  }

  /// Return a new result after applying a transformation (that itself
  /// returns a result) to a successful value.
  /// Calling with a failure returns a new failure without evaluating the transform
  public func flatMap<U>(transform:T -> Result<U,E>) -> Result<U,E> {
    switch self {
    case Success(let value): return transform(value.unbox)
    case Failure(let error): return .Failure(error)
    }
  }
}

extension Result: Printable {
  public var description: String {
    switch self {
    case .Success(let box):
      return "Success: \(box.unbox)"
    case .Failure(let error):
      return "Failure: \(error.unbox)"
    }
  }
}

/// Failure coalescing
///    .Success(Box(42)) ?? 0 ==> 42
///    .Failure(NSError()) ?? 0 ==> 0
public func ??<T,E>(result: Result<T,E>, @autoclosure defaultValue:  () -> T) -> T {
  switch result {
  case .Success(let value):
    return value.unbox
  case .Failure(let error):
    return defaultValue()
  }
}

/// Equatable
/// Equality for Result is defined by the equality of the contained types
public func ==<T, E where T: Equatable, E: Equatable>(lhs: Result<T, E>, rhs: Result<T, E>) -> Bool {
    switch (lhs, rhs) {
    case let (.Success(l), .Success(r)): return l.unbox == r.unbox
    case let (.Failure(l), .Failure(r)): return l.unbox == r.unbox
    default: return false
    }
}

public func !=<T, E where T: Equatable, E: Equatable>(lhs: Result<T, E>, rhs: Result<T, E>) -> Bool {
  return !(lhs == rhs)
}

/// Due to current swift limitations, we have to include this Box in Result.
/// Swift cannot handle an enum with multiple associated data (A, NSError) where one is of unknown size (A)
final public class Box<T> {
  public let unbox: T
  public init(_ value: T) { self.unbox = value }
}
