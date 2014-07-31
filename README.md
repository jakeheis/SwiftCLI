SwiftCLI
========

A lightweight framework than can be used to develop a CLI in Swift


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
