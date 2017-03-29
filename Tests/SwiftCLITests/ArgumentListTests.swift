//
//  ArgumentListTests.swift
//  SwiftCLI
//
//  Created by Jake Heiser on 3/29/17.
//
//

import XCTest
@testable import SwiftCLI

class ArgumentListTests: XCTestCase {
    
    static var allTests : [(String, (ArgumentListTests) -> () throws -> Void)] {
        return [
            ("testListIntegrity", testListIntegrity),
            ("testStringParse", testStringParse),
            ("testInsert", testInsert),
            ("testRemove", testRemove)
        ]
    }
    
    func testListIntegrity() {
        let list = ArgumentList(arguments: ["tester", "test", "thisCase", "-s", "-t", "5"])
        
        let first = list.head
        XCTAssert(first?.value == "test", "First value wrong")
        XCTAssert(first?.previous == nil, "First prev wrong")
        
        let second = first?.next
        XCTAssert(second?.value == "thisCase", "Second value wrong")
        XCTAssert(second?.previous?.value == "test", "Second prev wrong")
        
        let third = second?.next
        XCTAssert(third?.value == "-s", "Third value wrong")
        XCTAssert(third?.previous?.value == "thisCase", "Third prev wrong")
        
        let fourth = third?.next
        XCTAssert(fourth?.value == "-t", "Fourth value wrong")
        XCTAssert(fourth?.previous?.value == "-s", "Fourth prev wrong")
        
        let fifth = fourth?.next
        XCTAssert(fifth?.value == "5", "Fifth value wrong")
        XCTAssert(fifth?.previous?.value == "-t", "Fifth prev wrong")
        XCTAssert(fifth?.next == nil, "Fifth next wrong")
    }
    
    func testStringParse() {
        let easy = ArgumentList(argumentString: "tester test thisCase")
        XCTAssert(easy.head?.value == "test", "First wrong")
        XCTAssert(easy.head?.next?.value == "thisCase", "Second wrong")
        XCTAssert(easy.head?.next?.next == nil, "Second wrong")
        
        let doubleQuote = ArgumentList(argumentString: "tester \"hi\" \"hello\"")
        XCTAssert(doubleQuote.head?.value == "hi", "First wrong")
        XCTAssert(doubleQuote.head?.next?.value == "hello", "Second wrong")
        XCTAssert(doubleQuote.head?.next?.next == nil, "Second wrong")
        
        let singleQuote = ArgumentList(argumentString: "tester \"hi hello\"")
        XCTAssert(singleQuote.head?.value == "hi hello", "First wrong")
        XCTAssert(singleQuote.head?.next == nil, "First wrong")
    }
    
    func testInsert() {
        let list = ArgumentList(argumentString: "tester test thisCase")
        list.insert(value: "-q", after: list.head!)
        
        XCTAssert(list.head?.value == "test", "First wrong")
        
        XCTAssert(list.head?.next?.value == "-q", "Second wrong")
        XCTAssert(list.head?.next?.previous?.value == "test", "Second wrong")
        
        XCTAssert(list.head?.next?.next?.value == "thisCase", "Third wrong")
        XCTAssert(list.head?.next?.next?.previous?.value == "-q", "Third wrong")
        
        XCTAssert(list.head?.next?.next?.next == nil, "Third wrong")
    }
    
    func testRemove() {
        let list = ArgumentList(argumentString: "tester test -q thisCase")
        list.remove(node: list.head!.next!)
        
        XCTAssert(list.head?.value == "test", "First wrong")
        
        XCTAssert(list.head?.next?.value == "thisCase", "Second wrong")
        XCTAssert(list.head?.next?.previous?.value == "test", "Second wrong")
        
        XCTAssert(list.head?.next?.next == nil, "Third wrong")
    }
    
}
