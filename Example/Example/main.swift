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
    .withSignature("<food>")
    .onExecution({parameters, options in
        let yummyFood = parameters["food"] as String
        println("Eating \(yummyFood).")
        return (true, nil)
    })

CLI.go()