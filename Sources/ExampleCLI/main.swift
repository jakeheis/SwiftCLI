import SwiftCLI

class ExampleCommand: Command {
  let name = "example"

  let fastCar = Key<Car>("--fast-car",
    description: "A fast car",
    validation: [.isFast]
  )

  let swedishCar = Key<Car>("--swedish-car",
    description: "A Swedish car",
    validation: [.isSwedish]
  )

  let age = Key<Int>("--age",
    description: "Your age",
    validation: [.within(18...95)]
  )

  let person = Key<String>("--person",
    description: "Your name",
    validation: [.contains("Sir"), .min(7)]
  )

  func execute() throws {
    if let car = swedishCar.value {
      print("Got a swedish car:", car)
    }

    if let car = fastCar.value {
      print("Got a fast car:", car)
    }

    if let age = age.value {
      print("Got age:", age)
    }

    if let person = person.value {
      print("Got name:", person)
    }
  }
}

CLI(name: "Example", commands: [
  ExampleCommand(),
]).goAndExit()
