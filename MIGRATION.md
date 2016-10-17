SwiftCLI 2.0
==

In SwiftCLI 2.0, the library has been updated for Swift 3 as well as had a number of customization options made available. If you don't want the updated functionality but instead just code that works with Swift 3, use Version 1.3.0 instead of 2.0.0.

Command
===
Small changes were made in the Command protocol (formerly CommandType protocol)
```swift
// Old CommandType Implementation:

var commandName: String { get }
var commandSignature: String { get }
var commandShortDescription: String { get }
var commandShortcut: String? { get }

// New Command Implementation:
var name: String { get }
var signature: String { get }
var shortDescription: String { get }
```
Notably, `commandShortcut` is missing from the new protocol. In order to implement command shortcuts, check out the section on command aliases below.

OptionRegistry
===
Option methods have been renamed, but Xcode should automatically rename these for you. Just in case it doesn't:
```swift
// Old
public func onFlags(_ flags: [String], usage: String, block: FlagBlock?)
public func onKeys(_ keys: [String], usage: String, valueSignature: String, block: KeyBlock?)

// New
public func add(flags: [String], usage: String = "", block: @escaping FlagBlock)
public func add(keys: [String], usage: String = "", valueSignature: String = "value", block: @escaping KeyBlock)
```
Also worth noting is that a `FlagBlock` has no parameters, and a `KeyBlock` only has a value parameter.
```
// Before
onFlags(["-a"]) { (flag) in

}
onKeys(["-m"]) { (key, value) in

}

// Now
add(flags: ["-a"]) {
    // Notice that you no longer should type "{ (flag) in"
}
add(keys: ["-m"]) { (value) in
    // just (value), not (key, value)
}
Command Aliases
===
Command shortcuts have been generalized to allow for the mapping from any name to another name. Where before you might have done:
```swift
let cmd = ChainableCommand(name: "cmd").withShortcut("-c")
CLI.registerCommand(name: "cmd")
```
you now do:
```swift
let cmd = ChainableCommand(name: "cmd")
CLI.registerCommand(name: "cmd")
CLI.alias(from: "-c", to: cmd.name)
```
This means you're no longer limited to only having one shortcut per command, nor must you prefix the shortcut with "-".

Advanced Customization
===
There are now a number of protocols which may be implemented to customize CLI functionality further:
```swift
public protocol UsageStatementGenerator
public protocol MisusedOptionsMessageGenerator
public protocol RawArgumentParser
public protocol CommandArgumentParser
public protocol OptionParser
```
If you wish to replace the default implementations of any of these, just implement their respective functions on your own type and update CLI with your custom implementations. See https://github.com/jakeheis/SwiftCLI/blob/master/README.md#customization for more information.
