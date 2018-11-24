//
//  OptionRegistryTests.swift
//  SwiftCLI
//
//  Created by Jake Heiser on 3/29/17.
//
//

import XCTest
@testable import SwiftCLI

class OptionRegistryTests: XCTestCase {
    
    func testFlagDetection() {
        let cmd = FlagCmd()
        let options = OptionRegistry(routable: cmd)
        XCTAssert(options.flag(for: "-a") != nil, "Options should expect flags after a call to onFlags")
        XCTAssert(options.flag(for: "--alpha") != nil, "Options should expect flags after a call to onFlags")
        XCTAssert(options.key(for: "-a") == nil, "Options should parse no keys from only flags")
    }
    
    func testKeyDetection() {
        let cmd = KeyCmd()
        let options = OptionRegistry(routable: cmd)
        XCTAssert(options.key(for: "-a") != nil, "Options should expect keys after a call to onKeys")
        XCTAssert(options.key(for: "--alpha") != nil, "Options should expect keys after a call to onKeys")
        XCTAssert(options.flag(for: "-a") == nil, "Options should parse no flags from only keys")
    }
    
    func testVariadicDetection() {
        let cmd = VariadicKeyCmd()
        let options = OptionRegistry(routable: cmd)
        XCTAssertNotNil(options.key(for: "-f"))
        XCTAssertNotNil(options.key(for: "--file"))
    }
    
    func testMultipleRestrictions() {
        let cmd = MultipleRestrictionsCmd()
        let registry = OptionRegistry(routable: cmd)
        _ = registry.flag(for: "-a")
        _ = registry.flag(for: "-b")
        
        XCTAssertFalse(cmd.atMostOne.check())
        XCTAssertFalse(cmd.atMostOneAgain.check())
    }
    
}
