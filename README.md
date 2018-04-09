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

let greeter = CLI(name: "greeter")
greeter.commands = [GreetCommand()]
greeter.go()
```

```bash
~ > greeter greet world
Hello world!
```

With SwiftCLI, you get for free:
- Command routing
- Option parsing
- Help messages
- Usage statements
- Error messages when commands are used incorrectly
- Zsh completions

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
  * [Command groups](#command-groups)
  * [Shell completions](#shell-completions)
  * [Built-in commands](#built-in-commands)
  * [Input](#input)
  * [External tasks](#external-tasks)
  * [Customization](#customization)
    * [Aliases](#aliases)
  * [Running your CLI](#running-your-cli)
  * [Example](#example)

## Installation
### [Ice Package Manager](https://github.com/jakeheis/Ice)
```shell
> ice add jakeheis/Ice
```
### Swift Package Manager
Add SwiftCLI as a dependency to your project:

```swift
dependencies: [
    .package(url: "https://github.com/jakeheis/SwiftCLI", from: "4.0.0")
]
```

`4.0.0` has a number of breaking changes. Use `3.1.0` if you wish to use the new features without the breaking changes.

## Creating a CLI

When creating a `CLI`, a `name` is required, and a `version` and `description` are both optional.

```swift
let myCli = CLI(name: "greeter", version: "1.0.0", description: "Greeter - your own personal greeter")
```

You set commands through the `.commands` property:

```swift
myCli.commands = [myCommand, myOtherCommand]
```

Finally, to actually start the CLI, you call one of the `go` methods. In a production app, `go()` or `goAndExit()` should be used. These methods use the arguments passed to your CLI on launch.

```swift
// Use go if you want program execution to continue afterwards
myCli.go() 

// Use exitAndGo if you want your program to terminate after CLI has finished
myCli.exitAndGo()
```

When you are creating and debugging your app, you can use `debugGo(with:)` which makes it easier to pass an argument string to your app during development.
```swift
myCli.debugGo(with: "greeter greet")
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

    let loudly = Flag("-l", "--loudly", description: "Say the greeting loudly")

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
        for i in 0..<(numberOfTimes.value ?? 1) {
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

    let loudly = Flag("-l", "--loudly", description: "Say the greeting loudly")
    let whisper = Flag("-w", "--whisper", description: "Whisper the greeting")
    
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

Global options can be used to specify that every command should have a certain option. This is how the `-h` flag is implemented for all commands. Simply add an option to CLI's `.globalOptions` array (and optionally extend `Command` to make the option easy to access in your commands):

```swift
private let verboseFlag = Flag("-v")
extension Command {
    var verbose: Flag {
        return verboseFlag
    }
}

myCli.globalOptions.append(verboseFlag)
```

With this, every command now has a `verbose` flag.

By default, every command will have a `-h` flag which prints help information. You can turn this off by setting the CLI `helpFlag` to nil:

```swift
myCli.helpFlag = nil
```

#### Usage of options
As seen in the above examples, `Flag()` and `Key()` both take an optional `description` parameter. A concise description of what the option does should be included here. This allows the `HelpMessageGenerator` to generate a fully informative usage statement for the command.

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

## Command groups

Command groups provide a way for related commands to be nested under a certain namespace. Groups can themselves contain other groups.

```swift
class ConfigGroup: CommandGroup {
    let name = "config"
    let children = [GetCommand(), SetCommand()]
}
class GetCommand: Command {
    let name = "get"
    func execute() throws {}
}
class SetCommand: Command {
    let name = "set"
    func execute() throws {}
}
```

You can add a command group to your CLI's `.commands` array just as add a normal command:

```swift
greeter.commands = [ConfigGroup()]
```

```shell
> greeter config

Usage: greeter config <command> [options]

Commands:
  get
  set

> greeter config set
> greeter config get
```

## Shell completions

Zsh completions can be automatically generated for your CLI (bash completions coming soon).

```swift
let myCli = CLI(...)

let generator = ZshCompletionGenerator(cli: myCli)
generator.writeCompletions()
```

## Built-in commands
`CLI` has two built-in commands: `HelpCommand` and `VersionCommand`.

### Help Command
The `HelpCommand` can be invoked with `myapp help` or `myapp -h`. The `HelpCommand` first prints the app description (if any was given during `CLI.setup()`). It then iterates through all available commands, printing their name and their short description.

```bash
~ > greeter help
Greeter - your own personal greeter

Available commands:
- greet                Greets the given person
- help                 Prints this help information
```

If you don't want this command to be automatically included, set the `helpCommand` property to nil:

```swift
myCLI.helpCommand = nil
```

### Version Command
The `VersionCommand` can be invoked with `myapp version` or `myapp -v`. The VersionCommand prints the version of the app given during init `CLI(name:version:)`. If no version is given, the command is not available.

```bash
~ > greeter -v
Version: 1.0
```

If you don't want this command to be automatically included, set the `versionCommand` property to nil:

```swift
myCLI.versionCommand = nil
```

## Input

The `Input` class makes it easy to read input from stdin. Several methods are available:

```swift
let str = Input.readLine()
let int = Input.readInt()
let double = Input.readDouble()
let bool = Input.readBool()
```

All `read` methods have four optional parameters:
- `prompt`: the message to print before accepting input (e.g. "Input: ")
- `secure`: if true, the input is hidden as the user types
- `validation`: a closure which defines whether the input is valid, or if the user should be reprompted
- `errorResponse`: a closure which is executed when the user enters input which is not valid

For example, you could write:

```swift
let percentage = Input.readDouble(
    prompt: "Percentage:",
    validation: { $0 >= 0 && $0 <= 100 },
    errorResponse: { (input) in
        print("'\(input)' is invalid; must be a number between 0 and 100")
    }
)
```

which would result in interaction such as:

```shell
Percentage: asdf
'asdf' is invalid; must be a number between 0 and 100
Percentage: 104
'104' is invalid; must be a number between 0 and 100
Percentage: 43.6
```

## External tasks

SwiftCLI makes it easy to execute external tasks:

```swift
// Execute a command and print output:
try run("echo", "hello")
try run(bash: "while true; do echo hi && sleep 1; done")

// Execute a command and capture the output:
let currentDirectory = try capture("pwd").stdout
let sorted = try capture(bash: "cat Package.swift | sort").stdout
```

You can also use the `Task` class for more custom behavior:

```swift
let input = PipeStream()
let output = PipeStream()
let task = Task(executable: "sort", currentDirectory: "~/Ice", stdout: output, stdin: input)
task.runAsync()

input <<< "beta"
input <<< "alpha"
input.closeWrite()

output.readAll() // will be alpha\nbeta\n
```

See `Sources/SwiftCLI/Task.swift` for full documentation on `Task`.

## Customization

SwiftCLI was designed with sensible defaults but also the ability to be customized at every level. `CLI` has three properties that can be changed from the default implementations to customized implementations.

### `parser`

The `Parser` steps through arguments to find the corresponding command, update its parameter values, and recognize options. SwiftCLI supplies a default implementation of `Parser` with `DefaultParser`. `DefaultParser` finds commands based on the first passed argument (or, in the case of command groups, the first several arguments). For example, `greeter greet` would search for commands with the `name` of "greet".

SwiftCLI also supplies an implementation of `Parser` called `SingleCommandParser` which should be used if your command is only a single command. For example, if you were implementing the `ln` command, you would say `myCLI.parser = SingleCommandParser(command: LinkCommand())`. This parser will then always return the same command.

You can implement `Parser` on your own type and update CLI's property:

```swift
public var parser: Parser = DefaultParser()
```

#### Aliases
Aliases can be made through the the `aliases` property on CLI. `DefaultParser` will take these aliases into account while routing to the matching command. For example, if you write:

```swift
myCLI.aliases["-c"] = "command"
```

And the user makes the call `myapp -c`, the parser will search for a command with the name "command" because of the alias, not a command with the name "-c".

By default, "-h" is aliased to "help" and "-v" to "version", but you can remove these if they're not wanted:

```swift
myCLI.aliases["-h"] = nil
```

### `argumentListManipulators`

`ArgumentListManipulator`s act before the `Parser` begins. They take in the arguments as given by the user and can change them slightly. By default, the only argument list manipulator used is `OptionSplitter` which splits options like `-am` into `-a -m`.

You can implement `ArgumentListManipulator` on your own type and update CLI's property:

```swift
public var argumentListManipulators: [ArgumentListManipulator] = [OptionSplitter()]
```

### `helpMessageGenerator`

The messages formed by SwiftCLI can also be customized:

```swift
public var helpMessageGenerator: HelpMessageGenerator = DefaultHelpMessageGenerator()
```

## Running your CLI

Simply call `swift run`. In order to ensure your `CLI` gets the arguments passed on the command line, make sure to call `CLI.go()`, **not** ```CLI.debugGo(with: "")```.

## Example
An example of a CLI developed with SwfitCLI can be found at https://github.com/jakeheis/Ice.
