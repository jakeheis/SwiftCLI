//
//  PropertyWrapperSupport.swift
//  SwiftCLI
//
//  Created by Jake Heiser on 1/5/20.
//

// Necessary because property wrappers do not support inits with default values

extension Key {
    
    public convenience init(wrappedValue value: Value, _ name1: String) {
        self.init(designatedValue: value, names: [name1])
    }
    
    public convenience init(wrappedValue value: Value, _ name1: String, description: String) {
        self.init(designatedValue: value, names: [name1], description: description)
    }
    
    public convenience init(wrappedValue value: Value, _ name1: String, completion: ShellCompletion) {
        self.init(designatedValue: value, names: [name1], completion: completion)
    }
    
    public convenience init(wrappedValue value: Value, _ name1: String, validation: [Validation<Value>]) {
        self.init(designatedValue: value, names: [name1], validation: validation)
    }
    
    public convenience init(wrappedValue value: Value, _ name1: String, description: String, completion: ShellCompletion) {
        self.init(designatedValue: value, names: [name1], description: description, completion: completion)
    }
    
    public convenience init(wrappedValue value: Value, _ name1: String, description: String, validation: [Validation<Value>]) {
        self.init(designatedValue: value, names: [name1], description: description, validation: validation)
    }
    
    public convenience init(wrappedValue value: Value, _ name1: String, completion: ShellCompletion, validation: [Validation<Value>]) {
        self.init(designatedValue: value, names: [name1], completion: completion, validation: validation)
    }
    
    public convenience init(wrappedValue value: Value, _ name1: String, description: String, completion: ShellCompletion, validation: [Validation<Value>]) {
        self.init(designatedValue: value, names: [name1], description: description, completion: completion, validation: validation)
    }
    
    //
    
    public convenience init(wrappedValue value: Value, _ name1: String, _ name2: String) {
        self.init(designatedValue: value, names: [name1, name2])
    }
    
    public convenience init(wrappedValue value: Value, _ name1: String, _ name2: String, description: String) {
        self.init(designatedValue: value, names: [name1, name2], description: description)
    }
    
    public convenience init(wrappedValue value: Value, _ name1: String, _ name2: String, completion: ShellCompletion) {
        self.init(designatedValue: value, names: [name1, name2], completion: completion)
    }
    
    public convenience init(wrappedValue value: Value, _ name1: String, _ name2: String, validation: [Validation<Value>]) {
        self.init(designatedValue: value, names: [name1, name2], validation: validation)
    }
    
    public convenience init(wrappedValue value: Value, _ name1: String, _ name2: String, description: String, completion: ShellCompletion) {
        self.init(designatedValue: value, names: [name1, name2], description: description, completion: completion)
    }
    
    public convenience init(wrappedValue value: Value, _ name1: String, _ name2: String, description: String, validation: [Validation<Value>]) {
        self.init(designatedValue: value, names: [name1, name2], description: description, validation: validation)
    }
    
    public convenience init(wrappedValue value: Value, _ name1: String, _ name2: String, completion: ShellCompletion, validation: [Validation<Value>]) {
        self.init(designatedValue: value, names: [name1, name2], completion: completion, validation: validation)
    }
    
    public convenience init(wrappedValue value: Value, _ name1: String, _ name2: String, description: String, completion: ShellCompletion, validation: [Validation<Value>]) {
        self.init(designatedValue: value, names: [name1, name2], description: description, completion: completion, validation: validation)
    }
    
}

extension Param {
    
    public convenience init(wrappedValue value: Value) {
        self.init(designatedValue: value, completion: .filename, validation: [])
    }
    
}
