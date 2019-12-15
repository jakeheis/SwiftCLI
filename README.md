SwiftCLI
========

[![Build Status](https://github.com/jakeheis/SwiftCLI/workflows/Test/badge.svg)](https://github.com/jakeheis/SwiftCLI/actions)

A powerful framework for developing CLIs, from the simplest to the most complex, in Swift.

```swift
import SwiftCLI

class GreetCommand: Command {
    let name = "greet"
    
    @Param var person: String

    func execute() throws {
        stdout <<< "Hello \(person)!"
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

With SwiftCLI, you automatically get:
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
  * [Single command CLIs](#single-command-clis)
  * [Customization](#customization)
    * [Aliases](#aliases)
  * [Running your CLI](#running-your-cli)
  * [Example](#example)

## Installation
### [Ice Package Manager](https://github.com/jakeheis/Ice)
```shell
> ice add jakeheis/SwiftCLI
```
### Swift Package Manager
Add SwiftCLI as a dependency to your project:

```swift
dependencies: [
    .package(url: "https://github.com/jakeheis/SwiftCLI", from: "6.0.0")
]
```

### Carthage

```
github "jakeheis/SwiftCLI" ~> 5.2.2
```

### CocoaPods

```ruby
pod 'SwiftCLI', '~> 6.0.0'
```

## Creating a CLI

When creating a `CLI`, a `name` is required, and a `version` and `description` are both optional.

```swift
let myCli = CLI(name: "greeter", version: "1.0.0", description: "Greeter - a friendly greeter")
```

You set commands through the `.commands` property:

```swift
myCli.commands = [myCommand, myOtherCommand]
```

Finally, to run the CLI, you call one of the `go` methods.

```swift
// Use go if you want program execution to continue afterwards
myCli.go() 

// Use goAndExit if you want your program to terminate after the CLI has finished
myCli.goAndExit()

// Use go(with:) if you want to control the arguments which the CLI runs with
myCli.go(with: ["arg1", "arg2"])
```

## Commands

In order to create a command, you must implement the `Command` protocol. All that's required is to implement a `name` property and an `execute` function; the other properties of `Command` are optional (though a `shortDescription` is highly recommended). A simple hello world command could be created as such:

```swift
class GreetCommand: Command {

    let name = "greet"
    let shortDescription = "Says hello to the world"

    func execute() throws  {
        stdout <<< "Hello world!"
    }

}
```

### Parameters

A command can specify what parameters it accepts through certain instance variables. Using reflection, SwiftCLI will identify property wrappers of type `@Param` and `@CollectedParam`. These properties should appear in the order that the command expects the user to pass the arguments. All required parameters must come first, followed by any optional parameters, followed by at most one collected parameter.

```swift
class GreetCommand: Command {
    let name = "greet"

    @Param var first: String
    @Param var second: String?
    @CollectedParam var remaining: [String]
}
```

In this example, if the user runs `greeter greet Jack Jill up the hill`, `first` will contain the value `Jack`, `second` will contain the value `Jill`, and `remaining` will contain the value `["up", "the", "hill"]`.

#### @Param

Individual parameters take the form of the property wrapper `@Param`. Properties wrapped by `@Param` can be required or optional. If the command is not passed enough arguments to satisfy all required parameters, the command will fail.

```swift
class GreetCommand: Command {
    let name = "greet"

    @Param var person: String
    @Param var followUp: String

    func execute() throws {
        stdout <<< "Hey there, \(person)!"
        stdout <<< followUp
    }
}
```

```bash
~ > greeter greet Jack

Usage: greeter greet <person> <followUp> [options]

Options:
  -h, --help      Show help information

Error: command requires exactly 2 arguments

~ > greeter greet Jack "What's up?"
Hey there, Jack!
What's up?
```
If the user does not pass enough arguments to satisfy all optional parameters, the value of these unsatisfied parameters will be `nil`.

```swift
class GreetCommand: Command {
    let name = "greet"

    @Param var person: String
    @Param var followUp: String? // Note: String? in this example, not String

    func execute() throws {
        stdout <<< "Hey there, \(person)!"
        if let followUpText = followUp {
            stdout <<< followUpText
        }
    }
}
```

```bash
~ > greeter greet Jack
Hey there, Jack!
~ > greeter greet Jack "What's up?"
Hello, Jack!
What's up?
```

#### @CollectedParam

Commands may have a single collected parameter after all the other parameters called a `@CollectedParam`. This parameter allows the user to pass any number of arguments, and these arguments will be collected into the array wrapped by the collected parameter. The property wrapped by `@CollectedParam` **must** be an array. By default, `@CollectedParam` does not require the user to pass any arguments. The parameter can require a certain number of values by using the `@CollectedParam(minCount:)` initializer.

```swift
class GreetCommand: Command {
    let name = "greet"

    @CollectedParam(minCount: 1) var people: [String]

    func execute() throws {
        for person in people {
            stdout <<< "Hey there, \(person)!"
        }        
    }
}
```

```bash
~ > greeter greet Jack
Hey there, Jack!
~ > greeter greet Jack Jill Water
Hey there, Jack!
Hey there, Jill!
Hey there, Water!
```

#### Value type of parameter

With all of these parameter property wrappers, any type can be used so long as it conforms to `ConvertibleFromString`. Most primitive types (e.g. `Int`) conform to `ConvertibleFromString` already, as do enums with raw values that are primitive types. 

```swift
class GreetCommand: Command {
    let name = "greet"

    @Param var number: Int

    func execute() throws {
        stdout <<< "Hey there, number \(number)!"     
    }
}
```

```bash
~ > greeter greet Jack

Usage: greeter greet <number> [options]

Options:
  -h, --help      Show help information

Error: invalid value passed to 'number'; expected Int

~ > greeter greet 4
Hey there, number 4!
```

Parameters with enum types which conform to `CaseIterable` have additional specialized behavior. In an error message, the allowed values for that parameter will be spelled out.

```swift
class GreetCommand: Command {
    
    let name = "greet"
    
    enum Volume: String, ConvertibleFromString, CaseIterable {
        case loud
        case quiet
    }
    
    @Param var volume: Volume
    
    func execute() throws {
        let greeting = "Hello world!"
        
        switch volume {
        case .loud: stdout <<< greeting.uppercased()
        case .quiet: stdout <<< greeting.lowercased()
        }
        
    }
}
```

```bash
~ > greeter greet Jack

Usage: greeter greet <volume> [options]

Options:
  -h, --help      Show help information

Error: invalid value passed to 'volume'; expected one of: loud, quiet

~ > greet greet loud
HELLO WORLD!
```

To conform a custom type to `ConvertibleFromString`, simply implement one function:

```swift
extension MyType: ConvertibleFromString {
    init?(input: String) {
        // Construct an instance of MyType from the String, or return nil if not possible
        ...
    }
}
```

### Options

Commands have support for two types of options: flag options and keyed options. Both types of options can be denoted by either a dash followed by a single letter (e.g. `git commit -a`) or two dashes followed by the option name (e.g. `git commit --all`). Single letter options can be cascaded into a single dash followed by all the desired options: `git commit -am "message"` == `git commit -a -m "message"`.

Options are specified with property wrappers on the command class, just like parameters:

```swift
class ExampleCommand: Command {
    ...
    @Flag("-a", "--all")
    var flag: Bool

    @Key("-t", "--times")
    var key: Int?
    ...
}
```

#### Flags

Flags are simple options that act as boolean switches. For example, if you were to implement `git commit`, `-a` would be a flag option. They take the form of booleans wrapped by `@Flag`.

The `GreetCommand` could take a "loudly" flag:

```swift
class GreetCommand: Command {

    ...

    @Flag("-l", "--loudly", description: "Say the greeting loudly")
    var loudly: Bool

    func execute() throws {
        if loudly {
             ...
        } else {
            ...
        }
    }

}
```

A related option type is `@CounterFlag`, which counts the nubmer of times the user passes the same flag. `@CounterFlag` can only wrap properties of type `Int`. For example, with a flag declaration like:

```swift
class GreetCommand: Command {
    ...
    @CounterFlag("-s", "--softly", description: "Say the greeting softly")
    var softly: Int
    ...
}
```

the user can write `greeter greet -s -s`, and `softly.value` will be `2`.

#### Keys

Keys are options that have an associated value. Using "git commit" as an example, "-m" would be a keyed option, as it has an associated value - the commit message. They take the form of variables wrapped by '@Key`.

The `GreetCommand` could take a "number of times" option:

```swift
class GreetCommand: Command {

    ...

    @Key("-n", "--number-of-times", description: "Say the greeting a certain number of times")
    var numberOfTimes: Int?

    func execute() throws {
        for i in 0..<(numberOfTimes ?? 1) {
            ...
        }
    }

}
```

The variable wrapped by `@Key` can be any type conforming to `ConvertibleFromString` as described above. It **must** be optional, or the Swift compiler will crash.

A related option type is `VariadicKey`, which allows the user to pass the same key multiples times with different values. For example, with a key declaration like:

```swift
class GreetCommand: Command {
    ...
    @VariadicKey("-l", "--location", description: "Say the greeting in a certain location")
    var locations: [String]
    ...
}
```

the user can write `greeter greet -l Chicago -l NYC`, and `locations.value` will be `["Chicago", "NYC"]`. The variable wrapped by `@VariadicKey` must be an array of a type conforming to `ConvertibleFromString`.

#### Option groups

The relationship between multiple options can be specified through option groups. Option groups allow a command to specify that the user must pass at most one option of a group (passing more than one is an error), must pass exactly one option of a group (passing zero or more than one is an error), or must pass one or more options of a group (passing zero is an error). 

To add option groups, a `Command` should implement the property `optionGroups`. Option groups refer to options through the `$` syntax. For example, if the `GreetCommand` had a `loudly` flag and a `whisper` flag but didn't want the user to be able to pass both, an `OptionGroup` could be used:

```swift
class GreetCommand: Command {

    ...

    @Flag("-l", "--loudly", description: "Say the greeting loudly")
    var loudly: Bool

    @Flag("-w", "--whisper", description: "Whisper the greeting")
    var whisper: Bool
    
    var optionGroups: [OptionGroup] {
        return [.atMostOne($loudly, $whipser)] // Note: $loudly and $whisper, not loudly and whisper
    }

    func execute() throws {
        if loudly {
            ...
        } else if whisper {
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
    var verbose: Bool {
        return verboseFlag.value
    }
}

myCli.globalOptions.append(verboseFlag)
```

By default, every command has a `-h` flag which prints help information. You can turn this off by setting the CLI `helpFlag` to nil:

```swift
myCli.helpFlag = nil
```

#### Usage of options

As seen in the above examples, `@Flag` and `@Key` both take an optional `description` parameter. A concise description of what the option does should be included here. This allows the `HelpMessageGenerator` to generate a fully informative usage statement for the command.

A command's usage statement is shown in three situations:
- The user passed an option that the command does not support -- ```greeter greet -z```
- The user passed the wrong number of arguments
- The command's help was invoked -- `greeter greet -h`

```bash
~ > greeter greet -h

Usage: greeter greet <person> [options]

Options:
  -l, --loudly                          Say the greeting loudly
  -n, --number-of-times <value>         Say the greeting a certain number of times
  -h, --help                            Show help information for this command

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

Zsh completions can be automatically generated for your CLI.

```swift
let myCli = CLI(...)

let generator = ZshCompletionGenerator(cli: myCli)
generator.writeCompletions()
```

Completions will be automatically generated for command names and options. Parameter completion mode can be specified:

```swift
@Param(completion: .none)
var noCompletions: String

@Param(completion: .filename)
var aFile: String

@Param(completion: .values([
    ("optionA", "the first available option"),
    ("optionB", "the second available option")
]))
var aValue: String

@Param(completion: .function("_my_custom_func"))
var aFunction: String
```

The default parameter completion mode is `.filename`. If you specify a custom function with `.function`, that function must be supplied when creating the completion generator:

```swift
class MyCommand {
    ...
    @Param(completion: .function("_list_processes"))
    var pid: String
    ...
}

let myCLI = CLI(...)
myCLI.commands [MyCommand()]
let generator = ZshCompletionGenerator(cli: myCli, functions: [
    "_list_processes": """
        local pids
        pids=( $(ps -o pid=) )
        _describe '' pids
        """
])
```

## Built-in commands

`CLI` has two built-in commands: `HelpCommand` and `VersionCommand`.

### Help Command

The `HelpCommand` can be invoked with `myapp help`. The `HelpCommand` first prints the app description (if any was given during `CLI.init`). It then iterates through all available commands, printing their name and their short description.

```bash
~ > greeter help

Usage: greeter <command> [options]

Greeter - your own personal greeter

Commands:
  greet        Greets the given person
  help         Prints this help information

```

If you don't want this command to be automatically included, set the `helpCommand` property to nil:

```swift
myCLI.helpCommand = nil
```

### Version Command
The `VersionCommand` can be invoked with `myapp version` or `myapp --version`. The VersionCommand prints the version of the app given during init `CLI(name:version:)`. If no version is given, the command is not available.

```bash
~ > greeter --version
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
    validation: [.within(0...100)],
    errorResponse: { (input, reason) in
        Term.stderr <<< "'\(input)' is invalid; must be a number between 0 and 100"
    }
)
```

which would result in an interaction such as:

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
try Task.run("echo", "hello")
try Task.run(bash: "while true; do echo hi && sleep 1; done")

// Execute a command and capture the output:
let currentDirectory = try Task.capture("pwd").stdout
let sorted = try Task.capture(bash: "cat Package.swift | sort").stdout
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

## Single command CLIs

If your CLI only contains a single command, you may want to execute the command simply by calling `cli`, rather than `cli command`. In this case, you can create your CLI as such:

```swift
class Ln: Command {
    let name = "ln"
    func execute() throws { ... }
}

let ln = CLI(singleCommand: Ln())
ln.go()
```

In this case, if the user writes `ln myFile newLocation`, rather than searching for a command with the name "myFile", `SwiftCLI` will execute the `Ln` command and pass on "myFile" as the first argument to that command.

Keep in mind that when creating a single command CLI, you lose the default `VersionCommand`. This means that `cli -v` will not work automatically, and that if you want to print your CLI version you will need to manually implement a `Flag("-v")` on your single command.

## Customization

SwiftCLI was designed with sensible defaults but also the ability to be customized at every level. `CLI` has three properties that can be changed from the default implementations to customized implementations.

### `parser`

The `Parser` steps through arguments to find the corresponding command, update its parameter values, and recognizes options. Each CLI has a `parser` property which has three mutable properties: `routeBehavior`, `parseOptionsAfterCollectedParameter`, and `responders`.

`routeBehavior` has three possible values. The default, `.search`, steps through the arguments the user passed and tries to find a command with a matching name. If it fails, a help message is printed. `git` is an example of a program which operates this way. The second option, `.searchWithFallback(Command)`, also initially tries to find a command with a name matching the arguments passed by the user, but if it fails, rather than printing a help message it falls back to a certain command. 'bundle' is an example of a program which operates this way. The last option is `.automatically(Command)`. In this route behavior, the CLI automatically routes to the given command without considering arguments. 'ln' is an example of a program which operates this way.

`parseOptionsAfterCollectedParameter` controls whether or not options are recognized once a collected parameter is encountered. It defaults to `false`. Given the following command:

```swift
class Run: Command {
    let name = "run"

    @Param var executable: String
    @CollectedParam var arguments: [String]

    @Flag("-a") var all: Bool
    ...
}
```

if the user calls `swift run myExec -a` and `parseOptionsAfterCollectedParameter` is false, the value of `executable` will be "myExec", the value of `arguments` will be `["-a"]`, and the value of `all` will be false. If `parseOptionsAfterCollectedParameter` were true in this situation, the value of `executable` would be "myExec", the value of `arguments` would be `[]`, and the value of `all` would be true.

`responders` allows the parser to be completely customized. Check out `Parser.swift` for more information on how this functions by default and how it can be customized in any way.

### `aliases`

Aliases can be made through the the `aliases` property on CLI. `Parser` will take these aliases into account while routing to the matching command. For example, if you write:

```swift
myCLI.aliases["-c"] = "command"
```

And the user makes the call `myapp -c`, the parser will search for a command with the name "command" because of the alias, not a command with the name "-c".

By default, "--version" is an alias for "version", but you can remove this if desired:

```swift
myCLI.aliases["--version"] = nil
```

### `argumentListManipulators`

`ArgumentListManipulator`s act before the `Parser` begins. They take in the arguments as given by the user and can change them slightly. By default, the only argument list manipulator used is `OptionSplitter` which splits options like `-am` into `-a -m`.

You can implement `ArgumentListManipulator` on your own type and update CLI's property:

```swift
cli.argumentListManipulators.append(MyManipulator())
```

### `helpMessageGenerator`

The messages formed by SwiftCLI can also be customized:

```swift
cli.helpMessageGenerator = MyHelpMessageGenerator()
```

## Running your CLI

Simply call `swift run`. In order to ensure your `CLI` gets the arguments passed on the command line, make sure to call `CLI.go()`, **not** `CLI.go(with: [])`.

## CLIs build with SwiftCLI

- [XcodeGen](https://github.com/yonaskolb/XcodeGen)
- [Mint](https://github.com/yonaskolb/Mint)
- [SwiftKit](https://github.com/SvenTiigi/SwiftKit)
- [BartyCrouch](https://github.com/Flinesoft/BartyCrouch)
- [Ice](https://github.com/jakeheis/Ice)

