//
//  TaskTests.swift
//  SwiftCLITests
//
//  Created by Jake Heiser on 4/1/18.
//

import Foundation
import SwiftCLI
import XCTest

class TaskTests: XCTestCase {
    
    func testRun() throws {
        let file = "file.txt"
        try Task.run("/usr/bin/touch", file)
        
        XCTAssertTrue(FileManager.default.fileExists(atPath: file))
        try FileManager.default.removeItem(atPath: file)
    }
    
    func testCapture() throws {
        let path = "/tmp/_swiftcli"
        try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: false, attributes: nil)
        _ = FileManager.default.createFile(atPath: path + "/SwiftCLI", contents: nil, attributes: nil)
        defer { try! FileManager.default.removeItem(atPath: path) }
        
        let output = try Task.capture("/bin/ls", path)
        XCTAssertEqual(output.stdout, "SwiftCLI")
        XCTAssertEqual(output.stderr, "")
    }
    
    func testBashRun() throws {
        let file = "file.txt"
        try Task.run(bash: "touch \(file)")
        
        XCTAssertTrue(FileManager.default.fileExists(atPath: file))
        try FileManager.default.removeItem(atPath: file)
    }
    
    func testBashCapture() throws {
        let path = "/tmp/_swiftcli"
        try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: false, attributes: nil)
        _ = FileManager.default.createFile(atPath: path + "/SwiftCLI", contents: nil, attributes: nil)
        defer { try! FileManager.default.removeItem(atPath: path) }
        
        let output = try Task.capture(bash: "ls \(path)")
        XCTAssertEqual(output.stdout, "SwiftCLI")
        XCTAssertEqual(output.stderr, "")
    }
    
    func testRunDirectory() throws {
        let path = "/tmp/_swiftcli"
        try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: false, attributes: nil)
        defer { try! FileManager.default.removeItem(atPath: path) }
        
        try Task.run("touch", arguments: ["SwiftCLI"], directory: path)
        
        XCTAssertTrue(FileManager.default.fileExists(atPath: path + "/SwiftCLI"))
    }
    
    func testCaptureDirectory() throws {
        let path = "/tmp/_swiftcli"
        try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: false, attributes: nil)
        _ = FileManager.default.createFile(atPath: path + "/SwiftCLI", contents: nil, attributes: nil)
        defer { try! FileManager.default.removeItem(atPath: path) }
        
        let output = try Task.capture("ls", arguments: [], directory: path)
        XCTAssertEqual(output.stdout, "SwiftCLI")
        XCTAssertEqual(output.stderr, "")
    }
    
    func testIn() throws {
        let input = PipeStream()
        
        let output = CaptureStream()
        let task = Task(executable: "/usr/bin/sort", stdout: output, stdin: input)
        task.runAsync()
        
        input <<< "beta"
        input <<< "alpha"
        input.closeWrite()
        
        let code = task.finish()
        XCTAssertEqual(code, 0)
        XCTAssertEqual(output.readAll(), "alpha\nbeta\n")
    }
    
    func testPipe() throws {
        // Travis errors on Linux for unknown reason
        #if os(macOS)
        
        let path = "/tmp/_swiftcli"
        try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: false, attributes: nil)
        _ = FileManager.default.createFile(atPath: path + "/Info.plist", contents: nil, attributes: nil)
        _ = FileManager.default.createFile(atPath: path + "/LinuxMain.swift", contents: nil, attributes: nil)
        _ = FileManager.default.createFile(atPath: path + "/SwiftCLITests", contents: nil, attributes: nil)
        defer { try! FileManager.default.removeItem(atPath: path) }
        
        let connector = PipeStream()
        let output = CaptureStream()
        
        let ls = Task(executable: "ls", arguments: [path], stdout: connector)
        let grep = Task(executable: "grep", arguments: ["Swift"], stdout: output, stdin: connector)
        
        ls.runAsync()
        grep.runAsync()
                
        XCTAssertEqual(output.readAll(), "SwiftCLITests\n")
        
        #endif
    }
    
    func testCurrentDirectory() throws {
        let path = "/tmp/_swiftcli"
        try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: false, attributes: nil)
        _ = FileManager.default.createFile(atPath: path + "/SwiftCLI", contents: nil, attributes: nil)
        defer { try! FileManager.default.removeItem(atPath: path) }
        
        let capture = CaptureStream()
        
        let ls = Task(executable: "ls", directory: path, stdout: capture)
        ls.runSync()
        
        XCTAssertEqual(capture.readAll(), "SwiftCLI\n")
    }
    
    func testEnv() {
        let capture = CaptureStream()
        
        let echo = Task(executable: "bash", arguments: ["-c", "echo $MY_VAR"], stdout: capture)
        echo.env["MY_VAR"] = "aVal"
        echo.runSync()
        
        XCTAssertEqual(capture.readAll(), "aVal\n")
    }
    
    func testSignals() {
        let task = Task(executable: "/bin/sleep", arguments: ["1"])
        task.runAsync()
        
        XCTAssertTrue(task.suspend())
        sleep(2)
        XCTAssertTrue(task.isRunning)
        XCTAssertTrue(task.resume())
        sleep(2)
        XCTAssertFalse(task.isRunning)
        
        // Travis errors when calling interrupt on Linux for unknown reason
        #if os(macOS)
        let task2 = Task(executable: "/bin/sleep", arguments: ["3"])
        task2.runAsync()
        task2.interrupt()
        XCTAssertEqual(task2.finish(), 2)
        #endif
        
        let task3 = Task(executable: "/bin/sleep", arguments: ["3"])
        task3.runAsync()
        task3.terminate()
        XCTAssertEqual(task3.finish(), 15)
    }
    
    func testTaskLineStream() throws {
        let path = "/tmp/_swiftcli"
        try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: false, attributes: nil)
        _ = FileManager.default.createFile(atPath: path + "/Info.plist", contents: nil, attributes: nil)
        _ = FileManager.default.createFile(atPath: path + "/LinuxMain.swift", contents: nil, attributes: nil)
        _ = FileManager.default.createFile(atPath: path + "/SwiftCLITests", contents: nil, attributes: nil)
        defer { try! FileManager.default.removeItem(atPath: path) }
        
        var count = 0
        let lineStream = LineStream { (line) in
            count += 1
        }
        let task = Task(executable: "ls", arguments: [path], stdout: lineStream)
        XCTAssertEqual(task.runSync(), 0)
        
        XCTAssertEqual(count, 3)
    }
    
    func testTaskNullStream() throws {
        let task = Task(executable: "ls", stdout: WriteStream.null)
        task.runSync()
    }
    
}
