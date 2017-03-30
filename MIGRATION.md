# SwiftCLI 3.0
In SwiftCLI 3.0, arguments and options have been completely overhauled. They are now much easier to implement, with less boilerplate and increased clarity.

## Command
Command and OptionCommand have been unified in SwiftCLI 3.0. The way in which commands handle both argument and options has improved significantly.

### Arguments
Before, Commands would specify their parameters through the `signature` property, parameters are now specified in the command itself:
```swift
// Before
class GreetCommand: OptionCommand {
    let name = "greet"
    let signature = "<person>"
    ...
}

// Now:
class GreetCommand: Command {
    let name = "greet"
    let person = Parameter()
    ...
}
```

The available classes for parameters are: `Parameter`, `OptionalParameter`, `CollectedParameter`, and `OptionalCollectedParameter`.
```swift
// Before:
class GreetCommand: OptionCommand {
    let name = "greet"
    let signature = "<person> [<greeting>] [<otherWords>] ..."
    ...
}

// Now:
class GreetCommand: Command {
    let name = "greet"
    let person = Parameter()
    let greeting = OptionalParameter()
    let otherWords = OptionalCollectedParameter()
    ...
}
```

When it comes to accessing the values passed to these parameters, rather than using a type-unsafe string, use the `Parameter`s specified earlier:
```swift
// Before:
class GreetCommand: OptionCommand {
    let name = "greet"
    let signature = "<person>"
    func execute(arguments: CommandArguments) throws {
        let person = arguments.requiredArgument("person")
        print("Hi \(person)")
    }
}

// Now:
class GreetCommand: Command {
    let name = "greet"
    let person = Parameter()
    func execute() throws {
        print("Hi \(person.value)")
    }
}
```

### Options
As mentioned earlier, Command and OptionCommand have been unified, so all commands now can have options. Rather than adding the options in a `setupOptions` function, options should be specified as instance variables on the command itself:

```swift
// Before:
class GreetCommand: OptionCommand {
    let name = "greet"
    let signature = "<person>"

    var loudly = false
    var times = 1

    func setupOptions(options: OptionRegistry) {
        options.add(flags: ["-l", "--loudly"], usage: "") {
            self.loudly = true
        }
        options.add(keys: ["-t", "--times"], usage: "", valueSignature: "") { (value) in
            self.times = Int(value) ?? self.times
        }
    }

    func execute(arguments: CommandArguments) throws {
        let person = arguments.requiredArgument("person")
        for i in 0..<times {
            if loudly {
                print("HI \(person)!!!!!!")
            } else {
                print("Hi \(person)")
            }
        }
    }
}

// Now:
class GreetCommand: Command {
    let name = "greet"
    let person = Parameter()

    let loudly = Flag("-l", "--loudly")
    let times = Key<Int>("-t", "--times")

    func execute() throws {
        for i in 0..<(times.value ?? 1) {
            if loudly.value {
                print("HI \(person.value)!!!!!!")
            } else {
                print("Hi \(person.value)")
            }
        }
    }
}
```
The classes `Flag` and `Key<T>` should be used to specify options.
