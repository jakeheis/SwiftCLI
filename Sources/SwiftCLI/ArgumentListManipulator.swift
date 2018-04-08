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
    
    public init() {}
    
    public func manipulate(arguments: ArgumentList) {
        arguments.manipulate { (args) in
            var unsplit = args
            var split: [String] = []
            while let first = unsplit.first {
                unsplit.removeFirst()
                
                if first.hasPrefix("--"), let equalsIndex = first.index(of: "=") {
                    split.append(String(first[..<equalsIndex]))
                    split.append(String(first[first.index(after: equalsIndex)...]))
                } else if first.hasPrefix("-") && !first.hasPrefix("--") {
                    first.dropFirst().forEach {
                        split.append("-\($0)")
                    }
                } else {
                    split.append(first)
                }
            }
            return split
        }
    }
    
}
