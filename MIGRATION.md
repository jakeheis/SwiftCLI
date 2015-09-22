Big changes
=====

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

