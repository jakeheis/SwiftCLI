//
//  main.swift
//  Example
//
//  Created by Jake Heiser on 7/31/14.
//  Copyright (c) 2014 jakeheis. All rights reserved.
//

import Foundation

CLI.registerChainableCommand(commandName: "init")
    .withShortDescription("Creates a Bakefile in the current or given directory")
    .withSignature("[<directory>]")
    .onExecution({arguments, options in
        let givenDirectory = arguments["directory"] as String?
        
        let fileName = givenDirectory ? givenDirectory!.stringByAppendingPathComponent("Bakefile") : "./Bakefile"
        NSFileManager.defaultManager().createFileAtPath(fileName, contents: nil, attributes: nil)
        
        return (true, nil)
    })

CLI.go()