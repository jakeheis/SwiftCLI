SwiftCLI
========

[![Build Status](https://travis-ci.org/jakeheis/SwiftCLI.svg?branch=master)](https://travis-ci.org/jakeheis/SwiftCLI)

A powerful framework that can be used to develop a CLI, from the simplest to the most complex, in Swift.

```swift
import SwiftCLI

class GreetCommand: Command {
    let name = "greet"
    let person = Parameter()
    func execute() throws {
        print("Hello \(person.value)!")
    }
}

CLI.setup(name: "greeter")
CLI.register(command: GreetCommand())
CLI.go()
```
```bash
~ > greeter greet world
Hello world!
```

## Upgrading to SwiftCLI 3.0?

Check out the [migration guide](MIGRATION.md)!

Table of Contents
=================
  
  * [Installation](#installation)
  * [Creating a CLI](#creating-a-cli)
  * [Commands](#commands)
    * [Parameters](#parameters)
      * [Required parameters](#required-parameters)
      * [Optional parameters](#optional-parameters)
      * [Collected parameters](#collected-parameters)
    * [Options](#options)
      * [Flag options](#flag-options)
      * [Keyed options](#keyed-options)
      * [Option groups](#option-groups)
      * [Global options](#global-options)
  * [Routing commands](#routing-commands)
    * [Aliases](#aliases)
  * [Special commands](#special-commands)
  * [Input](#input)
  * [Customization](#customization)
  * [Running your CLI](#running-your-cli)
  * [Example](#example)

## Installation
Add SwiftCLI as a dependency to your project:
```swift
dependencies: [
    .Package(url: "https://github.com/jakeheis/SwiftCLI", majorVersion: 3, minor: 0)
]
```
## Creating a CLI
### Setup
In the call to `CLI.setup()`, a name must be passed, and a `version` and a `description` are both optional.
```swift
CLI.setup(name: "greeter", version: "1.0", description: "Greeter - your own personal greeter")
```
### Registering commands
```swift
CLI.register(command: myCommand)
CLI.register(commands: [myCommand, myOtherCommand])
```
### Calling go
In a production app, `go()` should be used. This method uses the arguments passed to it on launch.
```swift
CLI.go()
```
When you are creating and debugging your app, `debugGo(with:)` is the better choice. `debugGo(with:)` makes it easier to pass an argument string to your app during development.
```swift
CLI.debugGo(with: "greeter greet")
```

## Commands
In order to create a command, you must implement the `Command` protocol. All that's required is to implement a `name` property and an `execute` function; the other properties of `Command` are optional (though a `shortDescription` is highly recommended). A simple hello world command could be created as such:
```swift
class GreetCommand: Command {

    let name = "greet"
    let shortDescription = "Says hello to the world"

    func execute() throws  {
        print("Hello world!")
    }

}
```
### Parameters
A command can specify what parameters it accepts through certain instance variables. Using reflection, SwiftCLI will identify instance variables of type `Parameter`, `OptionalParameter`, `CollectedParameter`, and `OptionalCollectedParameter`. These instance variables should appear in the order that the command expects the user to pass the arguments:
```swift
class GreetCommand: Command {
    let name = "greet"
    let firstParam = Parameter()
    let secondParam = Parameter()
}
```
In this example, if the user runs `greeter greet Jack Jill`, `firstParam` will be updated to have the value `Jack` and `secondParam` will be updated to have the value `Jill`. The values of these parameters can be accessed in `func execute()` by calling `firstParam.value`, etc.

#### Required parameters

Required parameters take the form of the type `Parameter`. If the command is not passed enough arguments to satisfy all required parameters, the command will fail.

```swift
class GreetCommand: Command {
    let name = "greet"

    let person = Parameter()
    let greeting = Parameter()

    func execute() throws {
        print("\(greeting.value), \(person.value)!")
    }
}
```

```bash
~ > greeter greet Jack
Expected 2 arguments, but got 1.
~ > greeter greet Jack Hello
Hello, Jack!
```

#### Optional parameters

Optional parameters take the form of the type `OptionalParameter`. Optional parameters must come after all required parameters. If the user does not pass enough arguments to satisfy all optional parameters, the `.value` of these unsatisfied parameters will be `nil`.

```swift
class GreetCommand: Command {
    let name = "greet"

    let person = Parameter()
    let greeting = OptionalParameter()

    func execute() throws {
        let greet = greeting.value ?? "Hey there"
        print("\(greet), \(person.value)!")
    }
}
```

```bash
~ > greeter greet Jack
Hey there, Jack!
~ > greeter greet Jack Hello
Hello, Jack!
```

#### Collected parameters

Commands may have a single collected parameter, a `CollectedParameter` or a `OptionalCollectedParameter`. These parameters allow the user to pass any number of arguments, and these arguments will be collected into the `value` array of the collected parameter.

```swift
class GreetCommand: Command {
    let name = "greet"

    let people = CollectedParameter()

    func execute() throws {
        let peopleString = people.value.joined(separator: ", ")
        print("Hey there, \(peopleString)!")
    }
}
```

```bash
~ > greeter greet Jack
Hey there, Jack!
~ > greeter greet Jack Jill
Hey there, Jack, Jill!
~ > greeter greet Jack Jill Hill
Hey there, Jack, Jill, Hill!
```

### Options
Commands have support for two types of options: flag options and keyed options. Both types of options can either be denoted by a dash followed by a single letter (e.g. `git commit -a`) or two dashes followed by the option name (e.g. `git commit --all`). Single letter options can be cascaded into a single dash followed by all the desired options: `git commit -am "message"` == `git commit -a -m "message"`.

Options are specified as instance variables on the command class, just like parameters:
```swift
class ExampleCommand: Command {
    ...
    let flag = Flag("-a", "--all")
    let key = Key<Int>("-t", "--times")
    ...
}
```

#### Flag options
Flag options are simple options that act as boolean switches. For example, if you were to implement `git commit`, `-a` would be a flag option. They take the form of variables of the type `Flag`.

The ```GreetCommand``` could be modified to take a "loudly" flag:
```swift
class GreetCommand: Command {

    ...

    let loudly = Flag("-l", "--loudly", usage: "Say the greeting loudly")

    func execute() throws {
        if loudly.value {
             ...
        } else {
            ...
        }
    }

}
```

#### Keyed options
Keyed options are options that have an associated value. Using "git commit" as an example, "-m" would be a keyed option, as it has an associated value - the commit message. They take the form of variables of the generic type `Key<T>`, where `T` is the type of the option.

The ```GreetCommand``` could be modified to take a "number of times" option:
```swift
class GreetCommand: Command {

    ...

    let numberOfTimes = Key<Int>("-n", "--number-of-times", usage: "Say the greeting a certain number of times")

    func execute() throws {
        for i in 0..<(numberOfTimes ?? 1) {
            ...
        }
    }

}
```

#### Option groups

The relationship between multiple options can be specified through option groups. Option groups allow a command to specify that the user must pass at most one option of a group (passing more than one is an error), must pass exactly one option of a group (passing zero or more than one is an error), or must pass one or more options of a group (passing zero is an error). 

To add option groups, a `Command` should implement the property `optionGroups`. For example, if the `GreetCommand` had a `loudly` flag and a `whisper` flag but didn't want the user to be able to pass both, an `OptionGroup` could be used:

```swift
class GreetCommand: Command {

    ...

    let loudly = Flag("-l", "--loudly", usage: "Say the greeting loudly")
    let whisper = Flag("-w", "--whisper", usage: "Whisper the greeting")
    
    var optionGroups: [OptionGroup] {
        let volume = OptionGroup(options: [loudly, whisper], restriction: .atMostOne)
        return [volume]
    }

    func execute() throws {
        if loudly.value {
             ...
        } else {
            ...
        }
    }

}
```

#### Global options

Global options can be used to specify that every command should have a certain option. This is how the `-h` flag is implemented for all commands.

To add a global option, you must create a struct conforming to `GlobalOptionsSource` which contains static properties for the global options you wish to add, and an `options` static property that returns an array of these options. Finally, after calling `CLI.setup`, you should notify `CLI` of this new source of global options by calling `GlobalOptions.source(MyStruct.self)`.

```swift
struct MyGlobalOptions: GlobalOptionsSource {
    static let verbose = Flag("-v")
    static var options: [Option] {
        return [verbose]
    }
}

CLI.setup(name: "greeter")
GlobalOptions.source(MyGlobalOptions.self)
```

You can create a shortcut to this flag within every command by extending `Command`:

```swift
extension Command {
    var verbose: Flag {
        return MyGlobalOptions.verbose
    }
}
```

With this, every command now has a `verbose` flag.

#### Usage of options
As seen in the above examples, ```Flag()``` and ```Key()``` both take an optional ```usage``` parameter. A concise description of what the option does should be included here. This allows the `UsageStatementGenerator` to generate a fully informative usage statement for the command.

A command's usage statement is shown in two situations:
- The user passed an option that the command does not support -- ```greeter greet -z```
- The command's help was invoked -- `greeter greet -h`

```bash
~ > greeter greet -h
Usage: greeter greet <person> [options]

-l, --loudly                             Say the greeting loudly
-n, --number-of-times <value>            Say the greeting a certain number of times
-h, --help                               Show help information for this command
```

## Routing commands
Command routing is done by an object implementing `Router`, which is just one simple method:

```swift
func route(commands: [Command], arguments: ArgumentList) -> Command?
```

SwiftCLI supplies a default implementation of `Router` with `DefaultRouter`. `DefaultRouter` finds commands based on the first passed argument. For example, `greeter greet` would search for commands with the `name` of "greet". 

SwiftCLI also supplies an implementation of `Router` called `SingleCommandRouter` which should be used if your command is only a single command. For example, if you were implementing the `ln` command, you would say `CLI.router = SingleCommandRouter(command: LinkCommand())`.

If a command is not found, `CLI` outputs a help message.
```bash
~ > greeter
Greeter - your own personal greeter

Available commands:
- greet                Greets the given person
- help                 Prints this help information
```

### Aliases
Aliases can be made through the call `CommandAliaser.alias(from:to:)`. `Router` will take these aliases into account while routing to the matching command. For example, if this call is made:
```swift
CommandAliaser.alias(from: "-c", to: "command")
```
And the user makes the call `myapp -c`, the router will search for a command with the name "command" because of the alias, not a command with the name "-c".

## Special commands
`CLI` has two special commands: `helpCommand` and `versionCommand`.

### Help Command
The `HelpCommand` can be invoked with `myapp help` or `myapp -h`. The `HelpCommand` first prints the app description (if any was given during `CLI.setup()`). It then iterates through all available commands, printing their name and their short description.

```bash
~ > greeter help
Greeter - your own personal greeter

Available commands:
- greet                Greets the given person
- help                 Prints this help information
```

A custom `HelpCommand` can be used by calling `CLI.helpCommand = customHelp`.

### Version Command
The `VersionCommand` can be invoked with `myapp version` or `myapp -v`. The VersionCommand prints the version of the app given during `CLI.setup()`.

```bash
~ > greeter -v
Version: 1.0
```

A custom `VersionCommand` can be used by calling `CLI.versionComand = customVersion`.

## Input

The `Input` class wraps the handling of input from stdin. Several methods are available:

```swift
// Simple input:
public static func awaitInput(message: String?) -> String {}
public static func awaitInt(message: String?) -> Int {}
public static func awaitYesNoInput(message: String = "Confirm?") -> Bool {}

// Complex input (if the simple input methods are not sufficient):
public static func awaitInputWithValidation(message: String?, validation: (input: String) -> Bool) -> String {}
public static func awaitInputWithConversion<T>(message: String?, conversion: (input: String) -> T?) -> T {}
```

## Customization

SwiftCLI was designed with sensible defaults but also the ability to be customized at every level. ``CLI`` has six properties that can be changed from the default implementations to customized implementations.

Given a call like
```bash
~> baker bake cake -qt frosting
```

the flow of the CLI is as such:

```
User calls "baker bake cake -qt frosting"
    Command: ?
    Parameters: ?
    Options: ?
    Arguments: Node(bake) -> Node(cake) -> Node(-qt) -> Node(frosting)
ArgumentListManipulators() (including CommandAliaser() and OptionSplitter()) manipulate the nodes
    Command: ?
    Parameters: ?
    Options: ?
    Arguments: Node(bake) -> Node(cake) -> Node(-q) -> Node(-t) -> Node(frosting)
Router() uses the argument nodes to find the appropriate command
    Command: bake
    Parameters: ?
    Options: ?
    Arguments: Node(cake) -> Node(-q) -> Node(-t) -> Node(frosting)
OptionRecognizer() recognizes the options present within the argument nodes
    Command: bake
    Parameters: ?
    Options: quietly, topped with frosting
    Arguments: Node(cake)
ParameterFiller() fills the parameters of the routed command with the remaining arguments
    Command: bake
    Parameters: cake
    Options: quietly, topped with frosting
    Arguments: (none)
```
All four of these steps can be customized:
```swift
public static var argumentListManipulators: [ArgumentListManipulator] = [CommandAliaser(), OptionSplitter()]

public static var router: Router = DefaultRouter()

public static var optionRecognizer: OptionRecognizer = DefaultOptionRecognizer()

public static var parameterFiller: ParameterFiller = DefaultParameterFiller()
```

The messages formed by SwiftCLI can also be customized:

```swift
// Generate a usage statement for the given command
public static var usageStatementGenerator: UsageStatementGenerator = DefaultUsageStatementGenerator()

// Generate a misused options message for the given command with the given incorrect options
public static var misusedOptionsMessageGenerator: MisusedOptionsMessageGenerator = DefaultMisusedOptionsMessageGenerator()
```
See the individual files of each of these protocols in order to see how to provide a custom implementation.

## Running your CLI

After calling `swift build`, your executable should be available at `.build/debug/YourPackageName`. In order to ensure the `CLI` gets the arguments passed on the command line, make sure to call `CLI.go()`, **not** ```CLI.debugGo(with: "")```.

## Example
An example of a CLI developed with SwfitCLI can be found at https://github.com/jakeheis/Baker.
