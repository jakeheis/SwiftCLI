CommandType
===

Instead of subclassing `Command`, custom commands should now implement `CommandType` or `OptionCommandType`, depending on what functionality is needed.

```swift
// Old Command Sublcass:

public func commandName() -> String
public func commandSignature() -> String
public func commandShortDescription() -> String
public func commandShortcut() -> String?

// New CommandType Implementation:

var commandName: String { get }
var commandSignature: String { get }
var commandShortDescription: String { get }
var commandShortcut: String? { get }
```

If option handling functionality is now needed, `OptionCommandType` (which inherits from `CommandType`) should be implemented :

```swift
// Old Command Sublcass:

public func handleOptions()
public func showHelpOnHFlag() -> Bool // Default true
public func unrecognizedOptionsPrintingBehavior() -> UnrecognizedOptionsPrintingBehavior // Default .PrintAll
public func failOnUnrecognizedOptions() -> Bool // Default true 

// New CommandType Implementation:

func setupOptions(options: Options)
var helpOnHFlag: Bool { get } // Default still true
var unrecognizedOptionsPrintingBehavior: UnrecognizedOptionsPrintingBehavior { get } // Default still .PrintAll
var failOnUnrecognizedOptions: Bool { get } // Default still true
```

Error handling
===

In SwiftCLI 1.1, the `Result` type has been removed. This means that to indicate a command's success or failure, you no longer return `success()` or `failure()`. Instead, Swift 2's error handling functionality is utilized.

To indicate a command's failure, you throw an error from the command's execution block. Simply replacing `return failure("Command failed for a reason")` with `throw CLIError.Error("Command failed for a reason")` should be sufficient in most cases.

Errors that are thrown multiples times can be cleaned up as such:

```swift

class ReadCommand: CommandType {

	static let ReadingError = CLIError.Error("The file could not be read")
	
	...


	func execute(arguments: CommandArguments) throws {
		if something {
			throw ReadCommand.ReadingError
		}

		if somethingElse {
			throw ReadCommand.ReadingError	
		}
	}

	...

}
```

 If no errors are thrown in the duration of the command, the command is assumed to have succeeded.

Small changes
=====

