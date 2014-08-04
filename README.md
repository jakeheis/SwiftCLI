SwiftCLI
========

A lightweight framework than can be used to develop a CLI in Swift

```swift
//
//  main.swift
//  Example
//
//  Created by Jake Heiser on 7/31/14.
//  Copyright (c) 2014 jakeheis. All rights reserved.
//

import Foundation

CLI.setup(name: "greeter")
CLI.registerChainableCommand(commandName: "greet")
    .withExecutionBlock({arguments, options in
        println("Hey there!")
        return .Success
    })
CLI.go()
```
```bash
~ > greeter greet
Hey there!
```

## Creating a CLI
Setup the CLI:
```swift 
CLI.setup(name: "greeter", version: "1.0", description: "Greeter - your own personal greeter") 
```
Register all commands:
```swift
CLI.registerCommand(GreetCommand())
```
Just call go:
```swift
CLI.go()
```

## Commands
There are three ways to create a command. You should decided which way based upon how complex a command is. In order to clearly show how each method compares, the same command "greet" will be implemented each way.
### Subclass Command
You should create a command this way if it does some heavy lifting, i.e. there is a non trivial amount of code involved.
```swift
class GreetCommand: Command {
    
    override func commandName() -> String  {
        return "greet"
    }
    
    override func commandShortDescription() -> String  {
        return "Greets the given person"
    }
    
    override func commandSignature() -> String  {
        return "<person>"
    }
    
    override func execute() -> (success: Bool, error: String?)  {
        let person = self.arguments["person"] as String
        println("Hey there, \(person)!")
        return .Success
    }
}
```
### Create a ChainableCommand
You should only create this kind of command if the command is very simple and doesn't involve a lot of execution or option-handling code. It has all the same capabilities as a subclass of Command does, but it can quickly become bloated and hard to understand if there is a large amount of code involved.
```swift
let greetCommand = ChainableCommand(commandName: "greet")
    .withShortDescription("Greets the given person")
    .withSignature("<person>")
    .withExecutionBlock({arguments, options in
        let person = arguments["person"] as String
        println("Hey there, \(person)!")
        return .Success
    })
```
CLI also offers a shortcut method to register a ChainableCommand:
```swift
CLI.registerChainableCommand(commandName: "greet")
    .with...
```
### Create a LightweightCommand
This type of command is very similar to ChainableCommand. In fact, all ChainableCommand does is provide an alternative interface to its underlying LightweightCommand. As with ChainableCommands, this type of command should only be used when the command is relatively simple.
```swift
let greetCommand = LightweightCommand(commandName: "greet")
greetCommand.lightweightCommandShortDescription = "Greets the given person"
greetCommand.lightweightCommandSignature = "<person>"
greetCommand.lightweightExecutionBlock = {arguments, options in
    let person = arguments["person"] as String
    println("Hey there, \(person)!")
    return .Success
}
```


## Parameters
Each command must have a command signature describing its expected/permitted arguments. The command signature is used to map an array of arguments into a keyed dictionary. When a command is being executed, it is passed this dictionary of arguments, with the command signature segments used as keys and the user-passed arguments as values.

A signature of ```<person> <greeting>``` and a call of ```greeter greet Jack Hello``` would result in the arguments dictionary ```["greeting": "Hello", "person": "Jack"]```.

To set a command's signature:
- **Command subclass**: ```override func commandSignature() -> String  {}```
- **ChainableCommand**: ```.withSignature("")```
- **LightweightCommand**: ```cmd.lightweightCommandSignature = ""```

### Required parameters

Required parameters are surrounded by a less-than and a greater-than sign: ```<requiredParameter>``` If the command is not passed enough arguments to satisfy all required parameters, it will fail.

```bash
~ > # Greet command with a signature of "<person> <greeting>"
~ > greeter greet Jack
Expected 2 arguments, but got 1.
~ > greeter greet Jack Hello
Hello, Jack!
```

### Optional parameters

Optional parameters are surrounded by a less-than and a greater-than sign, and a set of brackets: ```[<optionalParameter>]``` Optional parameters must come after all required parameters.
```bash
~ > # Greet command with a signature of "<food> [<greeting>]"
~ > greeter greet Jack
Hey there, Jack!
~ > greeter greet Jack Hello
Hello, Jack!
``` 

### Non-terminal parameter

The non-terminal paremter is an elipses placed at the end of a command signature to signify that the last parameter can take an indefinite number of arguments. It must come at the very end of a command signature, after all required parameters and optional parameters.

```bash
~ > # Greet command with a signature of "<person> ..."
~ > greeter greet Jack
Hey there, Jack!
~ > greeter greet Jack Jill
Hey there, Jack and Jill!
~ > greeter greet Jack Jill Hill
Hey there, Jack, Jill, and Hill!
``` 

In the arguments dictionary, the non-terminal parameter results in all the last arguments being grouped into an array and passed to the parameter immediately before it (required or optional).

With one argument: ```greeter greet Jack``` -> ```["person": ["Jack"]]```

With multiple arguments: ```greeter greet Jack Jill Hill``` -> ```["person": ["Jack", "Jill", "Hill"]]```

## Options
Commands have support for two types of options: flag options and keyed options.

### Flag options
Flag options are simple options that act as boolean switches. They turn a part of a Command on or off. Using "git commit" as an example, "-a" would be a flag option - it signifies that the CommitCommand should stage and commit all files.

To configure a command for flag options:
- **Command subclass**: 
```
override func handleOptions() -> String  {
    self.onFlag("", block: {}, usage: "")
    self.onFlags([], block: {}, usage: "")
}
```
- **ChainableCommand**: ```.withFlagsHandled([], block: {}, usage: "")```
- **LightweightCommand**: ```cmd.handleFlags([], block: {}, usage: "")```

The ```GreetCommand``` could be modified to take a "loudly" flag:
```swift
class GreetCommand: Command {
    
    private var loudly = false
    
    ...
    
    override func handleOptions()  {
        self.onFlags(["-l", "--loudly"], block: {flag in
            self.loudly = true
        }, usage: "Makes the the greeting be said loudly")
    }
    
    ...
}
```

### Keyed options
Keyed options are options that have an associated value. Using "git commit" as an example again, "-m" would be a keyed option - it signifies the commit should have the associated message.

To configure a command for keyed options:
- **Command subclass**: 
```
override func handleOptions() -> String  {
    self.onKey("", block: {}, usage: "", valueSignature: "")
    self.onKeys([], block: {}, usage: "", valueSignature: "")
}
```
- **ChainableCommand**: ```.withKeysHandled([], block: {}, usage: "", valueSignature: "")```
- **LightweightCommand**: ```cmd.handleKeys([], block: {}, usage: "", valueSignature: "")```

The ```GreetCommand``` could be modified to take a "number of times" option:
```swift
class GreetCommand: Command {
    
    private var numberOfTimes = 1
    
    ...
    
    override func handleOptions()  {
        self.onKeys(["-n", "--number-of-times"], block: {key, value in
            if let times = value.toInt() {
                self.numberOfTimes = times
            }
        }, usage: "Makes the greeter greet a certain number of times", valueSignature: "times")
    }
    
    ...
}
```

### Handling all options
By default, if a command does not handle all options, the command will fail. This behavior can be changed to allow unhandled options:
- **Command subclass**: ```override func failOnUnhandledOptions() -> Bool { return false}```
- **ChainableCommand**: ```.withAllFlagsAndOptionsAllowed()```
- **LightweightCommand**: ```cmd.strictOnOptions = false```

### Options' usage
As seen in the above examples, ```onFlags``` and ```onKeys``` both take a ```usage``` parameter. A useful, concise description of what the option does should be included here. This allows the command's ```usageStatement()``` to be computed.

A command's ```usageStatement()``` is shown in two situations: 
- The user passed an option that the command does not support -- ```greeter greet -z```
- The command's help was invoked -- ```greeter greet -h```
```bash
~ > greeter greet -h
Usage: greeter greet <person> [options]

-l, --loudly                             Makes the the greeting be said loudly
-n, --number-of-times <times>            Makes the greeter greet a certain number of times
-h, --help                               Show help information for this command
```

Also worth noting, the ```valueSignature``` argument is what is shown for keyed arguments as such: ```<valueSignature>```


## Special commands
```CLI``` has three special commands: ```helpCommand```, ```versionCommand```, and ```defaultCommand```.

### Help Command
The default HelpCommand. It can be invoked with ```myapp help``` or ```myapp -h```. The HelpCommand first prints the app description (if any was given during ```CLI.setup()```). It then iterates through all available commands, printing their name and their short description.

```bash
~ > greeter help
Greeter - your own personal greeter

Available commands: 
- greet 	 Greets the given person
- help 	 Prints this help information
```

A custom HelpCommand can be used by calling ```CLI.registerCustomHelpCommand(customHelp)```.

### Version Command
It can be invoked with ```myapp version``` or ```myapp -v```. The VersionCommand prints the version of the app given during ```CLI.setup()```. 

```bash
~ > greeter -v
Version: 1.0
```

A custom VersionCommand can be used by calling ```CLI.registerCustomVersionCommand(customVersion)```.

### Default command
The default command is the command that is invoked if no command is specified. By default, this is simply the help command.
```bash
~ > greeter
Greeter - your own personal greeter

Available commands: 
- greet 	 Greets the given person
- help 	 Prints this help information
```

A custom default command can be specified by calling ```CLI.registerDefaultCommand(customDefault)```. Examples of when a custom default command would be used include ```cp```, ```bundle```, and many others.
