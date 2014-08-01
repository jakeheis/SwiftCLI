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
    .onExecution({arguments, options in
        let yummyFood = arguments["food"] as String
        let secondFood = arguments["secondFood"] as String?
        if let food2 = secondFood {
            println("Eating \(yummyFood) and \(food2).")
        } else {
            println("Eating \(yummyFood).")
        }
        return (true, nil)
    })

CLI.go()