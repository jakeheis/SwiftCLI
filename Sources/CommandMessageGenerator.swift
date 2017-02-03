//
//  CommandMessageGenerator.swift
//  Example
//
//  Created by Jake Heiser on 6/13/15.
//  Copyright © 2015 jakeheis. All rights reserved.
//

public protocol UsageStatementGenerator {
    func generateUsageStatement(for command: Command, optionRegistry: OptionRegistry?) -> String
}

public protocol MisusedOptionsMessageGenerator {
    func generateMisusedOptionsStatement(for command: Command, incorrectOptionUsage: IncorrectOptionUsage) -> String?
}

public class DefaultUsageStatementGenerator: UsageStatementGenerator {
    
    public func generateUsageStatement(for command: Command, optionRegistry: OptionRegistry?) -> String {
        var message = command.usage
        
        if let options = optionRegistry?.options, !options.isEmpty {
            
            if let groups = optionRegistry?.groups, !groups.isEmpty {
                
                var sortedGroups: Array<OptionGroup> = []
                for group in (groups.sorted { $0.name < $1.name }) where (group.name != "options" && group.required == true) {
                    sortedGroups.append(group)
                }
                for group in (groups.sorted { $0.name < $1.name }) where (group.name != "options" && group.required == false) {
                    sortedGroups.append(group)
                }
                sortedGroups.append(OptionGroup(name:"options",required:false,conflicting:false))
                
                let groupStrings = (sortedGroups.flatMap {
                    
                    (group) -> [String] in
                    let name = group.name
                    return [((group.required == true) ? " <\(group.name)>" : " [\(group.name)]")]
                    
                }).joined(separator: "")
                
                message += "\(groupStrings)\n"
                
                for group in sortedGroups {
                    
                    message += ((group.required == true) ? "\n<\(group.name)>" : "\n[\(group.name)]")
    
                    let groupOptions = options.filter() { $0.group == group.name }
                    
                    let sortedOptions = groupOptions.sorted { (lhs, rhs) in
                        return lhs.options.first! < rhs.options.first!
                    }
                    
                    for option in sortedOptions {
                        let maxSpacing = optionRegistry!.maxSpacing
                        let tempSpacing = (option.usage.components(separatedBy: "__SPACING_PLACEHOLDER__")[0]).characters.count
                        let spacing = String(repeating: " ", count: (maxSpacing - tempSpacing))
                        let usage = option.usage.replacingOccurrences(of: "__SPACING_PLACEHOLDER__", with: spacing)
                        message += "\n\(usage)"
                    }
                    message += "\n"
                }
                
            }
            else {
                assert(optionRegistry!.groups.contains(OptionGroup(name:"options")),"You can't delete the default options group.")
            }
        }
        else {
            message += "     (no options)\n"
        }
        
        return message
    }
    
}

public class DefaultMisusedOptionsMessageGenerator: MisusedOptionsMessageGenerator {

    public func generateMisusedOptionsStatement(for command: Command, incorrectOptionUsage: IncorrectOptionUsage) -> String? {
        guard let optionsCommand = command as? OptionCommand else {
            return nil
        }
        
        switch optionsCommand.unrecognizedOptionsPrintingBehavior {
        case .printNone:
            return nil
        case .printOnlyUsage:
            return CLI.usageStatementGenerator.generateUsageStatement(for: command, optionRegistry: incorrectOptionUsage.optionRegistry)
        case .printOnlyUnrecognizedOptions:
            return incorrectOptionUsage.misusedOptionsMessage()
        case .printAll:
            return CLI.usageStatementGenerator.generateUsageStatement(for: command, optionRegistry: incorrectOptionUsage.optionRegistry) + "\n" + incorrectOptionUsage.misusedOptionsMessage()
        }
    }
    
}
