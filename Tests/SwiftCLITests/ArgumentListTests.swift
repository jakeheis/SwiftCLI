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
        XCTAssertEqual(first?.value, "test", "First value wrong")
        XCTAssertNil(first?.previous, "First prev wrong")
        
        let second = first?.next
        XCTAssertEqual(second?.value, "thisCase", "Second value wrong")
        XCTAssertEqual(second?.previous?.value, "test", "Second prev wrong")
        
        let third = second?.next
        XCTAssertEqual(third?.value, "-s", "Third value wrong")
        XCTAssertEqual(third?.previous?.value, "thisCase", "Third prev wrong")
        
        let fourth = third?.next
        XCTAssertEqual(fourth?.value, "-t", "Fourth value wrong")
        XCTAssertEqual(fourth?.previous?.value, "-s", "Fourth prev wrong")
        
        let fifth = fourth?.next
        XCTAssertEqual(fifth?.value, "5", "Fifth value wrong")
        XCTAssertEqual(fifth?.previous?.value, "-t", "Fifth prev wrong")
        XCTAssertNil(fifth?.next, "Fifth next wrong")
    }
    
    func testStringParse() {
        let easy = ArgumentList(argumentString: "tester test thisCase")
        XCTAssertEqual(easy.head?.value, "test", "First wrong")
        XCTAssertEqual(easy.head?.next?.value, "thisCase", "Second wrong")
        XCTAssertNil(easy.head?.next?.next, "Second wrong")
        
        let doubleQuote = ArgumentList(argumentString: "tester \"hi\" \"hello\"")
        XCTAssertEqual(doubleQuote.head?.value, "hi", "First wrong")
        XCTAssertEqual(doubleQuote.head?.next?.value, "hello", "Second wrong")
        XCTAssertNil(doubleQuote.head?.next?.next, "Second wrong")
        
        let singleQuote = ArgumentList(argumentString: "tester \"hi hello\"")
        XCTAssertEqual(singleQuote.head?.value, "hi hello", "First wrong")
        XCTAssertNil(singleQuote.head?.next, "First wrong")
    }
    
    func testInsert() {
        let list = ArgumentList(argumentString: "tester test thisCase")
        list.insert(value: "-q", after: list.head!)
        
        XCTAssertEqual(list.head?.value, "test", "First wrong")
        
        XCTAssertEqual(list.head?.next?.value, "-q", "Second wrong")
        XCTAssertEqual(list.head?.next?.previous?.value, "test", "Second wrong")
        
        XCTAssertEqual(list.head?.next?.next?.value, "thisCase", "Third wrong")
        XCTAssertEqual(list.head?.next?.next?.previous?.value, "-q", "Third wrong")
        
        XCTAssertNil(list.head?.next?.next?.next, "Third wrong")
    }
    
    func testRemove() {
        let list = ArgumentList(argumentString: "tester test -q thisCase")
        list.remove(node: list.head!.next!)
        
        XCTAssertEqual(list.head?.value, "test", "First wrong")
        
        XCTAssertEqual(list.head?.next?.value, "thisCase", "Second wrong")
        XCTAssertEqual(list.head?.next?.previous?.value, "test", "Second wrong")
        
        XCTAssertNil(list.head?.next?.next, "Third wrong")
    }
    
}
