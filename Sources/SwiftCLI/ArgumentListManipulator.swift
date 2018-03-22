//
//  ArgumentListManipulator.swift
//  SwiftCLI
//
//  Created by Jake Heiser on 3/28/17.
//  Copyright © 2017 jakeheis. All rights reserved.
//

/// Protocol representing an object which can manipulate an ArgumentList. After creating a class which conforms
/// to this protocol, add it to CLI.argumentListManipulators
public protocol ArgumentListManipulator {
    func manipulate(arguments: ArgumentList)
}

/// Splits options represented by a single node into multiple nodes; e.g. command -ab -> command -a -b, --option=value -> --option value
public class OptionSplitter: ArgumentListManipulator {
    
    public func manipulate(arguments: ArgumentList) {
        let iterator = arguments.iterator()
        while let node = iterator.next() {
            if node.value.hasPrefix("--"), let equalsIndex = node.value.index(of: "=") {
                arguments.insert(value: String(node.value[node.value.index(after: equalsIndex)...]), after: node)
                node.value = String(node.value[..<equalsIndex])
            } else if node.value.hasPrefix("-") && !node.value.hasPrefix("--") {
                var previous = node
                node.value.dropFirst().forEach {
                    previous = arguments.insert(value: "-\($0)", after: previous)
                }
                arguments.remove(node: node)
            }
        }
    }
    
}
