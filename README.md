SwiftCLI
========

A powerful framework than can be used to develop a CLI, from the simplest to the most complex, in Swift.

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
    .withExecutionBlock {(arguments, options) in
        println("Hey there!")
        return success()
    }
CLI.go()
```
```bash
~ > greeter greet
Hey there!
```

## Contents
* [Creating a CLI](#creating-a-cli)
* [Commands](#commands)
* [Parameters](#parameters)
* [Options](#options)
* [Special Commands](#special-commands)
* [Running your CLI](#running-your-cli)
* [Installation](#swiftcli-installation)
* [Example](#example)

## Creating a CLI
### Setup
In the call to ```CLI.setup()```, a ```name``` must be passed, and a ```version``` and a ```description``` are both optional.
```swift 
CLI.setup(name: "greeter", version: "1.0", description: "Greeter - your own personal greeter")
```
### Registering commands
```swift
CLI.registerCommand(myCommand)
CLI.registerCommands([myCommand, myOtherCommand])
```
### Calling go
In any production app, ```go()``` should be used. This method uses the arguments passed to it on launch.
```swift
CLI.go()
```
When you are creating and debugging your app, ```debugGoWithArgumentString()``` is the better choice. Xcode does make it possible to pass arguments to a command line app on launch by editing the app's scheme, but this can be a pain. ```debugGoWithArgumentString()``` makes it easier to pass an argument string to your app during development.
```swift
CLI.debugGoWithArgumentString("greeter greet")
```

## Commands
There are three ways to create a command. You should decide which way to create your command based on how complex the command will be. In order to highlight the differences between the different command creation methods, the same command "greet" will be implemented each way.

### Subclass Command
This is usually the best choice for a command. Any command that involves a non-trivial amount of execution or option-handling code should be created with this method. A command subclass provides a structured way to develop a complex command, keeping it organized and easy to read.
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
    
    override func execute() -> ExecutionResult  {
        let person = arguments.requiredString("person")
        println("Hey there, \(person)!")
        return success()
    }
    
}
```
### Create a ChainableCommand
This is the most lightweight option. You should only create this kind of command if the command is very simple and doesn't involve a lot of execution or option-handling code. It has all the same capabilities as a subclass of Command does, but it can quickly become bloated and hard to understand if there is a large amount of code involved.
```swift
let greetCommand = ChainableCommand(commandName: "greet")
    .withShortDescription("Greets the given person")
    .withSignature("<person>")
    .withExecutionBlock {(arguments, options) in
        let person = arguments.requiredString("person")
        println("Hey there, \(person)!")
        return success()
    }
```
```CLI``` also offers a shortcut method to register a ChainableCommand:
```swift
CLI.registerChainableCommand(commandName: "greet")
    .with...
```
### Create a LightweightCommand
This type of command is very similar to ChainableCommand. In fact, all ChainableCommand does is provide an alternative interface to its superclass, LightweightCommand. As with ChainableCommands, this type of command should only be used when the command is relatively simple.
```swift
let greetCommand = LightweightCommand(commandName: "greet")
greetCommand.lightweightCommandShortDescription = "Greets the given person"
greetCommand.lightweightCommandSignature = "<person>"
greetCommand.lightweightExecutionBlock = {(arguments, options) in
    let person = arguments.requiredArgument("person")
    println("Hey there, \(person)!")
    return success()
}
```


## Parameters
Each command must have a command signature describing its expected/permitted arguments. The command signature is used to map the array of user-passed arguments into a keyed dictionary. When a command is being executed, it is passed this dictionary of arguments, with the command signature segments used as keys and the user-passed arguments as values.

For example, a signature of ```<person> <greeting>``` and a call of ```greeter greet Jack Hello``` would result in the arguments dictionary ```["greeting": "Hello", "person": "Jack"]```.

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
~ > # Greet command with a signature of "<person> [<greeting>]"
~ > greeter greet Jack
Hey there, Jack!
~ > greeter greet Jack Hello
Hello, Jack!
``` 

### Collection operator

The collection operator is an ellipses placed at the end of a command signature to signify that the last parameter can take an indefinite number of arguments. It must come at the very end of a command signature, after all required parameters and optional parameters.

```bash
~ > # Greet command with a signature of "<person> ..."
~ > greeter greet Jack
Hey there, Jack!
~ > greeter greet Jack Jill
Hey there, Jack and Jill!
~ > greeter greet Jack Jill Hill
Hey there, Jack, Jill, and Hill!
``` 

The collection operator results in all the last arguments being grouped into an array and passed to the parameter immediately before it (required or optional).

With one argument: ```greeter greet Jack``` -> ```["person": ["Jack"]]```

With multiple arguments: ```greeter greet Jack Jill Hill``` -> ```["person": ["Jack", "Jill", "Hill"]]```

### Accessing arguments

During execution, a command has access to an instance of ```CommandArguments``` that contains the passed arguments which have been keyed using the command signature. Arguments can be accessed with subscripts or the typesafe shortcuts ```CommandArguments``` includes:
```
override func execute() -> ExecutionResult  {
    // Given command signature --- <name>
    let name = arguments.requiredArgument("name") // of type String
    
    // Given command signature --- [<name>]
    let name = arguments.optionalArgument("name") // of type String?
    
    // Given command signature --- <names> ...
    let names = arguments.requiredCollectedArgument("names") // of type [String]
    
    // Given command signature --- [<names>] ...
    let names = arguments.optionalCollectedArgument("names") // of type [String]?
}
```

## Options
Commands have support for two types of options: flag options and keyed options. Both types of options can either be denoted by a dash followed by a single letter ```git commit -a``` or two dashes followed by the option name ```git commit --ammend```. Single letter options can be cascaded into a single dash followed by all the desired options: ```git commit -am``` == ```git commit -a -m```.

### Flag options
Flag options are simple options that act as boolean switches. For example, if you were to implement "git commit", "-a" would be a flag option.

To configure a command for flag options:
- **Command subclass**: 
```
override func handleOptions() -> String  {
    onFlag("", usage: "") {(flag) in
        
    }
    onFlags([], usage: "") {(flag) in
        
    }
}
```
- **ChainableCommand**: ```.withFlagsHandled([], usage: "") {}```
- **LightweightCommand**: ```cmd.handleFlags([], usage: "") {}```

The ```GreetCommand``` could be modified to take a "loudly" flag:
```swift
class GreetCommand: Command {
    
    private var loudly = false
    
    ...
    
    override func handleOptions()  {
        onFlags(["-l", "--loudly"], usage: "Makes the the greeting be said loudly") {(flag) in
            self.loudly = true
        }
    }
    
    ...
}
```

### Keyed options
Keyed options are options that have an associated value. Using "git commit" as an example again, "-m" would be a keyed option, as it has an associated value - the commit message.

To configure a command for keyed options:
- **Command subclass**: 
```
override func handleOptions() -> String  {
    onKey("", usage: "", valueSignature: "") {(key, value) in
    
    }
    onKeys([], usage: "", valueSignature: "") {(key, value) in
    
    }
}
```
- **ChainableCommand**: ```.withKeysHandled([], usage: "", valueSignature: "") {}```
- **LightweightCommand**: ```cmd.handleKeys([], usage: "", valueSignature: "") {}```

The ```GreetCommand``` could be modified to take a "number of times" option:
```swift
class GreetCommand: Command {
    
    private var numberOfTimes = 1
    
    ...
    
    override func handleOptions()  {
        onKeys(["-n", "--number-of-times"], usage: "Makes the greeter greet a certain number of times", valueSignature: "times") {(key, value) in
            if let times = value.toInt() {
                self.numberOfTimes = times
            }
        }
    }
    
    ...
}
```

### Unrecognized options
By default, if a command is passed any options it does not handle through ```onFlag(s)``` or ```onKey(s)```, or their respective equivalents in ```ChainableCommand``` and ```LightweightCommand```, the command will fail. This behavior can be changed to allow unrecognized options:
- **Command subclass**: ```override func failOnUnrecognizedOptions() -> Bool { return false}```
- **ChainableCommand**: ```.withAllFlagsAndOptionsAllowed()```
- **LightweightCommand**: ```cmd.shouldFailOnUnrecognizedOptions = false```

### Usage of options
As seen in the above examples, ```onFlags``` and ```onKeys``` both take a ```usage``` parameter. A concise description of what the option does should be included here. This allows the command's ```usageStatement()``` to be computed.

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

The ```valueSignature``` argument in the ```onKeys``` family of methods is displayed like a parameter following the key: ```--my-key <valueSignature>```.


## Special commands
```CLI``` has three special commands: ```helpCommand```, ```versionCommand```, and ```defaultCommand```.

### Help Command
The ```HelpCommand``` can be invoked with ```myapp help``` or ```myapp -h```. The ```HelpCommand``` first prints the app description (if any was given during ```CLI.setup()```). It then iterates through all available commands, printing their name and their short description.

```bash
~ > greeter help
Greeter - your own personal greeter

Available commands: 
- greet                Greets the given person
- help                 Prints this help information
```

A custom ```HelpCommand``` can be used by calling ```CLI.registerCustomHelpCommand(customHelp)```.

### Version Command
The ```VersionCommand``` can be invoked with ```myapp version``` or ```myapp -v```. The VersionCommand prints the version of the app given during ```CLI.setup()```. 

```bash
~ > greeter -v
Version: 1.0
```

A custom ```VersionCommand``` can be used by calling ```CLI.registerCustomVersionCommand(customVersion)```.

### Default command
The default command is the command that is invoked if no command is specified. By default, this is simply the help command.
```bash
~ > greeter
Greeter - your own personal greeter

Available commands: 
- greet                Greets the given person
- help                 Prints this help information
```

A custom default command can be specified by calling ```CLI.registerDefaultCommand(customDefault)```.

## Running your CLI

### Within Xcode
There are two methods to pass in arguments to your CLI within Xcode, explained below. After the arguments are set up using one of these methods, you just need to Build and Run, and your app will execute and print its ouput in Xcode's Console.

##### CLI ```debugGoWithArgumentString()```
As discussed before, this is the easiest way to pass arguments to the CLI. Just replace the ```CLI.go()``` call with ```CLI.debugGoWithArgumentString("")```. This is only appropriate for development, as when this method is called, the CLI disregards any arguments passed in on launch.

##### Xcode Scheme
This is not recommended, as the above option is simpler, but it is included for completions's sake. First click on your app's scheme, then "Edit Scheme...". Go to the "Run" section, then the "Arguments" tab. You can then add arguments where it says "Arguments Passed On Launch".

Make sure to use ```CLI.go()``` with this method, **not** ```CLI.debugGoWithArgumentString("")```.

### In Terminal
To actually make your CLI accessible and executable outside of Xcode, you need to add a symbolic link somewhere in your $PATH to the exectuable product Xcode outputs. The easiest way to do this is to click on your project in Xcode, then your executable target, then Build Phases. Add a new Run Script with this command:
```sh
lowercase_name=`echo $PRODUCT_NAME | tr '[A-Z]' '[a-z]'`
new_path=/usr/local/bin/$lowercase_name

if [ ! -f $new_path ]; then ln -s "$BUILT_PRODUCTS_DIR/$PRODUCT_NAME" "$new_path";fi
```
If you would rather have the symbolic link be placed in a different directory on your $PATH, change ```/usr/local/bin``` to your directory of choice. Also, if you would like the app to be executed with a different name then the product name, change the ```lowercase_name``` on the first line to your custom name.

You then need to Build your app once inside of Xcode. From then on, you should be able to access your CLI in your terminal.

Again, be sure to use ```CLI.go()``` with this method, not ```CLI.debugGoWithArgumentString("")```.

## SwiftCLI Installation

Right now, Swift frameworks cannot be embedded into command line tools, meaning CocoaPods and Carthage can't easily be used. There is a [way to get around this](http://colemancda.github.io/programming/2015/02/12/embedded-swift-frameworks-osx-command-line-tools/), but it's so difficult that using Git submodules is easier.

In your project directory, run:
```bash
git submodule add https://github.com/jakeheis/SwiftCLI.git
git submodule update --init --recursive
```
Then drag the SwiftCLI/SwiftCLI folder into your Xcode project:

![alt tag](https://github.com/jakeheis/SwiftCLI/blob/master/Example/DragScreenshot.png)

![alt tag](https://github.com/jakeheis/SwiftCLI/blob/master/Example/AddFiles.png)

## Example
An example of a CLI developed with SwfitCLI can be found in the Example directory in this repo.

The example project is a command called "baker" - a command to cook you whatever food you would like. It includes three commands, one implemented in each method described in the "Commands" section above - init, list, and bake.

To run the Example project, Build it, and then in your terminal enter in "baker".
