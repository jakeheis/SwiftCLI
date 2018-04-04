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
            ("testCapture", testCapture),
            ("testExecutableFind", testExecutableFind),
            ("testBashExec", testBashExec),
            ("testBashCapture", testBashCapture),
            ("testIn", testIn),
            ("testPipe", testPipe),
            ("testCurrentDirectory", testCurrentDirectory),
            ("testEnv", testEnv)
        ]
    }
    
    func testExec() throws {
        let file = "file.txt"
        try SwiftCLI.run("/usr/bin/touch", file)
        
        XCTAssertTrue(FileManager.default.fileExists(atPath: file))
        try FileManager.default.removeItem(atPath: file)
    }
    
    func testCapture() throws {
        let output = try capture("/bin/ls", "Sources")
        XCTAssertEqual(output.stdout, "SwiftCLI")
        XCTAssertEqual(output.stderr, "")
    }
    
    func testExecutableFind() throws {
        XCTAssertEqual(Task.findExecutable(named: "ls"), "/bin/ls")
        
        let output = try capture("ls", "Sources")
        XCTAssertEqual(output.stdout, "SwiftCLI")
        XCTAssertEqual(output.stderr, "")
    }
    
    func testBashExec() throws {
        let file = "file.txt"
        try SwiftCLI.run(bash: "touch \(file)")
        
        XCTAssertTrue(FileManager.default.fileExists(atPath: file))
        try FileManager.default.removeItem(atPath: file)
    }
    
    func testBashCapture() throws {
        let output = try capture(bash: "ls Sources")
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
        XCTAssertEqual(out.awaitContent(), "alpha\nbeta\n")
    }
    
    func testPipe() {
        let (read, write) = Task.createPipe()
        let capture = CaptureStream()
        
        let ls = Task(executable: "ls", args: ["Tests"], stdout: write)
        let grep = Task(executable: "grep", args: ["Swift"], stdout: capture, stdin: read)
        
        ls.runAsync()
        grep.runAsync()
                
        XCTAssertEqual(capture.awaitContent(), "SwiftCLITests\n")
    }
    
    func testCurrentDirectory() {
        let capture = CaptureStream()
        
        let ls = Task(executable: "ls", currentDirectory: "Sources", stdout: capture)
        ls.runSync()
        
        XCTAssertEqual(capture.awaitContent(), "SwiftCLI\n")
    }
    
    func testEnv() {
        let capture = CaptureStream()
        
        let echo = Task(executable: "bash", args: ["-c", "echo $MY_VAR"], stdout: capture)
        echo.env["MY_VAR"] = "aVal"
        echo.runSync()
        
        XCTAssertEqual(capture.awaitContent(), "aVal\n")
    }
    
}
