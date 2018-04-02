//
//  TaskTests.swift
//  SwiftCLITests
//
//  Created by Jake Heiser on 4/1/18.
//

import XCTest
import SwiftCLI

class TaskTests: XCTestCase {
    
    static var allTests : [(String, (TaskTests) -> () throws -> Void)] {
        return [
            ("testExec", testExec),
            ("testCapture", testCapture)
        ]
    }
    
    func testExec() throws {
        let file = "file.txt"
        try Task.execute("/usr/bin/touch", file)
        
        XCTAssertTrue(FileManager.default.fileExists(atPath: file))
        try FileManager.default.removeItem(atPath: file)
    }
    
    func testCapture() throws {
        let output = try Task.capture("/bin/ls", "Sources")
        XCTAssertEqual(output.stdout, "SwiftCLI")
        XCTAssertEqual(output.stderr, "")
    }
    
    func testExecutableFind() throws {
        XCTAssertEqual(Task.findExecutable(named: "ls"), "/bin/ls")
        
        let output = try Task.capture("ls", "Sources")
        XCTAssertEqual(output.stdout, "SwiftCLI")
        XCTAssertEqual(output.stderr, "")
    }
    
    func testBashExec() throws {
        let file = "file.txt"
        try Task.execute(bash: "touch \(file)")
        
        XCTAssertTrue(FileManager.default.fileExists(atPath: file))
        try FileManager.default.removeItem(atPath: file)
    }
    
    func testBashCapture() throws {
        let output = try Task.capture(bash: "ls Sources")
        XCTAssertEqual(output.stdout, "SwiftCLI")
        XCTAssertEqual(output.stderr, "")
    }
    
    func testIn() throws {
        let (read, write) = Task.createPipe()
        
        let out = CaptureStream()
        let task = Task(executable: "sort", stdout: out, stdin: read)
        task.runAsync()
        
        write <<< "beta"
        write <<< "alpha"
        write.close()
        
        let code = task.finish()
        XCTAssertEqual(code, 0)
        XCTAssertEqual(out.content, "alpha\nbeta\n")
    }
    
}
