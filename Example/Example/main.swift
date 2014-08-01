//
//  main.swift
//  Example
//
//  Created by Jake Heiser on 7/31/14.
//  Copyright (c) 2014 jakeheis. All rights reserved.
//

import Foundation

CLI.registerChainableCommand(commandName: "eat")
    .withShortDescription("Eats the given food")
    .withSignature("<food> [<secondFood>]")
    .allowFlags(["-f", "--quickly"])
    .onExecution({arguments, options in
        let yummyFood = arguments["food"] as String
        let secondFood = arguments["secondFood"] as String?
        
        var str = ""
        if let food2 = secondFood {
            str = "Eating \(yummyFood) and \(food2)"
        } else {
            str = "Eating \(yummyFood)"
        }
        
        println("options \(options)")
        
        return (true, nil)
    })

CLI.go()