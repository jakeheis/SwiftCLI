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
        return (true, nil)
    })
CLI.go()
```
```bash
~ > greeter greet
Hey there!
```

## Commands
There are 3 ways to create a command.
### Subclass Command
You should create a command this way if it does some heavy lifting, i.e. there is a non trivial amount of code involved.
```swift
class EatCommand: Command {
    
    override class var command: EatCommand {
        return EatCommand()
    }
    
    override var commandName: String  {
        return "eat"
    }
    
    override var commandShortDescription: String {
        return "Eats all given food"
    }
    
    override func commandSignature() -> String  {
        return "<food>"
    }
    
    override func execute() -> (success: Bool, error: NSError?)  {
        let yummyFood = self.parameters["food"] as String
        println("Eating \(yummyFood).")
        return (true, nil)
    }
    
}
```
### Create an instance of LightweightCommand
This type of command is the middleground between subclassing Command and creating a ChainableCommand - its for if the command involves a decent amount of execution code, but not enough to warrant its own subclass.
```swift
let lightweightCommand = LightweightCommand()
lightweightCommand.lightweightCommandName = "eat"
lightweightCommand.lightweightCommandShortDescription = "Eats the given food"
lightweightCommand.lightweightCommandSignature = "<food>"
lightweightCommand.lightweightExecutionBlock = {parameters, options in
    let yummyFood = parameters["food"] as String
    println("Eating \(yummyFood).")
    return (true, nil)
}
```
### Create a ChainableCommand
You should create this kind of command if the command is relatively simple and doesn't involve a lot of execution or option-handling code.
```swift
ChainableCommand(commandName: "eat")
    .withShortDescription("Eats the given food")
    .withSignature("<food>")
    .onExecution({parameters, options in
        let yummyFood = parameters["food"] as String
        println("Eating \(yummyFood).")
        return (true, nil)
    })
```

## Parameters
Each command has a command signature. A command signature looks like ```<firstParam> <secondParam>```. A command signature is used to map an arguments into a keyed dictionary. When a command is being executed, it is passed an ```NSDictionary``` of arguments, with the command signature segments used as keys, and the user-passed arguments as values.

A command signature of ```<food>``` and a command invocation of ```baker bake cake``` would result in ```["food": "cake"]``` being passed to the ```bake``` command. Similarly, if you were implementing a copy-file command, the signature might look like "<sourceFile> <targetFile>", the call might look like "cp myfile.file newfile.file", and the resulting arguments dictionary would look like ```["sourceFile": "myfile.file", "targetFile": "newfile.file"]```

### Required parameters

Required parameters are surrounded by a less-than and a greater-than sign: ```<requiredParameter>``` If the command is not passed enough arguments to satisfy all required parameters, the command will fail, returning a message with the format "Expected 1 argument, but got 0."

### Optional parameters

Optional parameters are surrounded by a less-than and a greater-than sign, and a set of brackets: ```[<optionalParameter>]``` Optional parameters must come after all required parameters.

### Non-terminal parameter

The non-terminal paremter is an elipses placed at the end of a command signature to signify that the last last parameter can take an indefinite number of arguments. 

The signature ```<food> ...``` means that at least one food must be passed to the command, but it will also accept any more. ```eater eat cake``` and ```eater eat cake cookie frosting``` are both valid command invocations with this signature. 
