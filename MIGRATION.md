SwiftCLI has been updated in version 1.1 to take advantage of new features in Swift 2.0. This includes a new protocol oriented design (which is much more elegant than the class inheritance based structure of SwiftCLI 1.0) and the usage of Swift 2.0's new error handling functionality.

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

- Option setup calls should now be called on the `options` objected passed in rather on the command itself. For example, where you used to call:
```swift
public func handleOptions() {
	onFlags(...)
}
```
you now call:
```swift
func setupOptions(options: Options) {
	options.onFlags(...)
}
```
- `LightweightCommand` properties no longer have the prefix `lightweight`. For example, `command.lightweightCommandName = "greet"` had become `command.commandName = "greet"`.
- Options setup for `LightweightCommands` and `ChainableCommands` is no longer done in specialized methods such as `handleFlags(...)` and `withFlagsHandled()`. Instead, a single closure should be passed with either `optionsSetupBlock = {(options) in }` or `withOptionsSetup {(options) in }`.
- `CLI` now has severable top level variables that can be directly set:
```swift
CLI.appName = "greeter"
CLI.appVersion = "1.0"
CLI.appDescription = "My description"
    
CLI.helpCommand: HelpCommand? = customHelpCommand
CLI.versionComand: CommandType? = customVersionCommand
CLI.defaultCommand: CommandType = otherDefaultCommand
```
- Documentation on most public methods is now available! Just option click as you usually do.
