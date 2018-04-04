//
//  StreamTests.swift
//  SwiftCLITests
//
//  Created by Jake Heiser on 4/2/18.
//

import XCTest
@testable import SwiftCLI

class StreamTests: XCTestCase {
    
    static var allTests : [(String, (StreamTests) -> () throws -> ())] {
        return [
            ("testWrite", testWrite),
            ("testCapture", testCapture),
            ("testRead", testRead),
            ("testReadAll", testReadAll),
            ("testReadLine", testReadLine),
            ("testReadLineDelayed", testReadLineDelayed),
            ("testReadLines", testReadLines)
        ]
    }
    
    func testWrite() {
        let text = "first line\nsecond line"
        
        let pipe = Pipe()
        let write = WriteStream(fileHandle: pipe.fileHandleForWriting)
        
        write.write(text)
        write.close()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        XCTAssertEqual(String(data: data, encoding: .utf8), text)
    }
    
    func testCapture() {
        let text = "first line\nsecond line"
        
        let capture = CaptureStream()
        
        capture.write(text)
        capture.close()
        
        XCTAssertEqual(capture.awaitContent(), text)
    }
    
    func testRead() {
        let (read, write) = Task.createPipe()
        
        write <<< "first line"
        XCTAssertEqual(read.read(), "first line\n")
        
        write <<< "second line"
        XCTAssertEqual(read.read(), "second line\n")
    }
    
    func testReadAll() {
        let (read, write) = Task.createPipe()
        
        write <<< "first line"
        write <<< "second line"
        write.close()
        
        XCTAssertEqual(read.readAll(), "first line\nsecond line\n")
    }
    
    func testReadLine() {
        let (read, write) = Task.createPipe()
        
        write <<< """
        first line
        
        second line
        
        """
        write.close()
        
        XCTAssertEqual(read.readLine(), "first line")
        XCTAssertEqual(read.readLine(), "")
        XCTAssertEqual(read.readLine(), "second line")
        XCTAssertEqual(read.readLine(), "")
        XCTAssertEqual(read.readLine(), nil)
        
    }

    // DispatchQueue errors on Linux on Swifts < 4.1
    #if os(macOS) || swift(>=4.1)
    func testReadLineDelayed() {
        let (read, write) = Task.createPipe()
        
        write.write("first ")
        
        DispatchQueue.global().asyncAfter(deadline: .now() + .seconds(1)) {
            write.write("line\nlast ")
        }
        
        DispatchQueue.global().asyncAfter(deadline: .now() + .milliseconds(1500)) {
            write.write("line")
            write.close()
        }
        
        XCTAssertEqual(read.readLine(), "first line")
        XCTAssertEqual(read.readLine(), "last line")
        XCTAssertEqual(read.readLine(), nil)
    }
    #endif
    
    func testReadLines() {
        let (read, write) = Task.createPipe()
        
        write <<< """
        first line
        
        second line
        
        """
        write.close()
        
        XCTAssertEqual(Array(read.readLines()), ["first line", "", "second line", ""])
    }
    
}
