# SwiftCLI 5.0
In SwiftCLI 5.0, much of the internal parsing logic has been reworked to allow for greater flexibility.

## Breaking changes

### `Command`

- The `value` property of `OptionalCollectedParameter` is no longer of type `[String]?` but rather just `[String]`. If the user does not pass any arguments for that parameter, the value will be an empty array rather than `nil`.
- Once the parser encouters a `CollectedParameter`, options will no longer be recognized and all arguments will be passed to the collected parameter. For example, given this command:

    ```swift
    class RunCommand: Command {
        let name = "run"
        let silent = Flag("-s")
        let executable = Parameter()
        let args = OptionalCollectedParameter()
    }
    ```
    
    If the user calls `cli run executable arg1 -s arg2`, then `args.value` will be `["arg1", "-s", "arg2]` and `silent.value` will remain false.

### `CommandGroup`

- `sharedOptions` has been renamed `options`

### Customization

- CLI properties `router`, `optionRecognzier`, and `parameterFiller` have been combined into the `parser` property.
- `Router` and `ParameterFiller` have been completely reworked; see `Parser.swift` for more details
- `OptionRecognizer` was removed
- `HelpMessageGenerator` functions now use SwiftCLI streams for simplicity's sake
- `ArgumentList` has been dramatically simplified, and `ArgumentListManipulator`s must be updated to work with the simplified implementation