//
//  ArgumentListManipulator.swift
//  SwiftCLI
//
//  Created by Jake Heiser on 3/28/17.
//
//

public protocol ArgumentListManipulator {
    func manipulate(arguments: ArgumentList)
}

public class CommandAliaser: ArgumentListManipulator {
    
    private var aliases: [String: String] = [
        "-h": "help",
        "-v": "version"
    ]
    
    public func manipulate(arguments: ArgumentList) {
        guard let commandNode = arguments.head else {
            return
        }
        if let alias = aliases[commandNode.value] {
            commandNode.value = alias
            
        }
    }
    
    public func alias(from: String, to: String) {
        aliases[from] = to
    }
    
    public func removeAlias(from: String) {
        aliases.removeValue(forKey: from)
    }
    
}

public class OptionSplitter: ArgumentListManipulator {
    
    public func manipulate(arguments: ArgumentList) {
        let iterator = arguments.iterator()
        while let node = iterator.next() {
            if node.value.hasPrefix("-") && !node.value.hasPrefix("--") {
                var previous = node
                node.value.characters.dropFirst().forEach {
                    print($0)
                    previous = arguments.insert(node: "-\($0)", after: previous)
                }
                arguments.remove(node: node)
            }
        }
    }
    
}
