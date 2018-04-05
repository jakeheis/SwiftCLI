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
            ("testWriteData", testWriteData),
            ("testRead", testRead),
            ("testReadData", testReadData),
            ("testReadAll", testReadAll),
            ("testReadLine", testReadLine),
            ("testReadLines", testReadLines),
        ]
    }
    
    // MARK: - Write
    
    func testWrite() {
        let text = "first line\nsecond line"
        
        let pipe = Pipe()
        let write = WriteStream(writeHandle: pipe.fileHandleForWriting)
        
        write.write(text)
        write.close()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        XCTAssertEqual(String(data: data, encoding: .utf8), text)
    }
    
    func testWriteData() {
        let data = "someString".data(using: .utf8)!
        
        let pipe = Pipe()
        let write = WriteStream(writeHandle: pipe.fileHandleForWriting)
        write.writeData(data)
        write.close()
        
        XCTAssertEqual(pipe.fileHandleForReading.readDataToEndOfFile(), data)
    }
    
    // MARK: - Read
    
    func testRead() {
        let pipe = Pipe()
        let read = ReadStream(readHandle: pipe.fileHandleForReading)
        
        let first = "first line\n"
        pipe.fileHandleForWriting.write(first.data(using: .utf8)!)
        XCTAssertEqual(read.read(), first)
        
        let second = "second line\n"
        pipe.fileHandleForWriting.write(second.data(using: .utf8)!)
        XCTAssertEqual(read.read(), second)
    }
    
    func testReadData() {
        let data = "someString".data(using: .utf8)!
        
        let pipe = Pipe()
        let read = ReadStream(readHandle: pipe.fileHandleForReading)
        pipe.fileHandleForWriting.write(data)
        XCTAssertEqual(read.readData(), data)
    }
    
    func testReadAll() {
        let pipe = PipeStream()
        
        pipe <<< "first line"
        pipe <<< "second line"
        pipe.closeWrite()
        
        XCTAssertEqual(pipe.readAll(), "first line\nsecond line\n")
    }
    
    func testReadLine() {
        let pipe = PipeStream()
        
        pipe <<< """
        first line
        
        second line
        
        """
        pipe.closeWrite()
        
        XCTAssertEqual(pipe.readLine(), "first line")
        XCTAssertEqual(pipe.readLine(), "")
        XCTAssertEqual(pipe.readLine(), "second line")
        XCTAssertEqual(pipe.readLine(), "")
        XCTAssertEqual(pipe.readLine(), nil)
        
        // DispatchQueue errors on Linux on Swifts < 4.1
        #if os(macOS) || swift(>=4.1)
        
        let pipe2 = PipeStream()
        
        pipe2.write("first ")
        
        DispatchQueue.global().asyncAfter(deadline: .now() + .seconds(1)) {
            pipe2.write("line\nlast ")
        }
        
        DispatchQueue.global().asyncAfter(deadline: .now() + .milliseconds(1500)) {
            pipe2.write("line")
            pipe2.closeWrite()
        }
        
        XCTAssertEqual(pipe2.readLine(), "first line")
        XCTAssertEqual(pipe2.readLine(), "last line")
        XCTAssertEqual(pipe2.readLine(), nil)
        
        #else
        
        print("Note: not running Dispatch test")
        
        #endif
    }
    
    func testReadLines() {
        let pipe = PipeStream()
        
        pipe <<< """
        first line
        
        second line
        
        """
        pipe.closeWrite()
        
        XCTAssertEqual(Array(pipe.readLines()), ["first line", "", "second line", ""])
    }
    
}
