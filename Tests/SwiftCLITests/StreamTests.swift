//
//  StreamTests.swift
//  SwiftCLITests
//
//  Created by Jake Heiser on 4/2/18.
//

import XCTest
import Dispatch
@testable import SwiftCLI

class StreamTests: XCTestCase {
    
    // MARK: - Write
    
    func testWrite() {
        let text = "first line\nsecond line"
        
        let pipe = Pipe()
        let write = WriteStream.for(fileHandle: pipe.fileHandleForWriting)
        
        write.write(text)
        write.closeWrite()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        XCTAssertEqual(String(data: data, encoding: .utf8), text)
    }
    
    func testWriteData() {
        let data = "someString".data(using: .utf8)!
        
        let pipe = Pipe()
        let write = WriteStream.for(fileHandle: pipe.fileHandleForWriting)
        write.writeData(data)
        write.closeWrite()
        
        XCTAssertEqual(pipe.fileHandleForReading.readDataToEndOfFile(), data)
    }
    
    // MARK: - Read
    
    func testRead() {
        let pipe = Pipe()
        let read = ReadStream.for(fileHandle: pipe.fileHandleForReading)
        
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
        let read = ReadStream.for(fileHandle: pipe.fileHandleForReading)
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
    
    func testLineStream() {
        let firstLine = expectation(description: "first line")
        let stream = LineStream { (line) in
            if line == "first" {
                firstLine.fulfill()
            }
        }
        
        stream <<< "first"
        waitForExpectations(timeout: 1)
        
        stream.closeWrite()
        stream.waitToFinishProcessing()
    }
    
    func testCaptureStream() {
        var lastChunk = Data()
        let semaphore = DispatchSemaphore(value: 0)
        let capture = CaptureStream() { data in
            lastChunk = data
            semaphore.signal()
        }
        let testCapture = { (input: String) in
            capture <<< input
            semaphore.wait()
            let encodedChunk = String(data: lastChunk, encoding: .utf8)?.trimmingCharacters(in: .newlines) ?? ""
            XCTAssertEqual(encodedChunk, input)
        }

        testCapture("first")
        testCapture("")
        testCapture("second")
        capture.closeWrite()
        
        XCTAssertEqual(capture.readAll(), """
        first

        second
        
        """)
    }
    
    func testNullStream() {
        let nullWrite = WriteStream.null
        
        nullWrite <<< "into"
        nullWrite <<< "the"
        nullWrite <<< "void"
    }
    
    func testReadFile() {
        let stream = ReadStream.for(path: #file)
        XCTAssertEqual(stream?.readLine(), "//")
        XCTAssertEqual(stream?.readLine(), "//  StreamTests.swift")
        
        stream?.seek(to: 0)
        XCTAssertEqual(stream?.readLine(), "//")
        XCTAssertEqual(stream?.readLine(), "//  StreamTests.swift")
        
        stream?.seekToEnd()
        XCTAssertNil(stream?.readLine())
    }
    
    func testWriteFile() {
        let path = "/tmp/SwiftCLI.test"
        defer { try? FileManager.default.removeItem(atPath: path) }
        
        guard let stream = WriteStream.for(path: path) else {
            XCTFail()
            return
        }
        
        stream <<< "first line"
        stream <<< "second line"
        
        XCTAssertEqual(String(data: FileManager.default.contents(atPath: path)!, encoding: .utf8), """
        first line
        second line
        
        """)
        
        guard let secondStream = WriteStream.for(path: path, appending: false) else {
            XCTFail()
            return
        }
        secondStream.write("newww text")
        
        XCTAssertEqual(String(data: FileManager.default.contents(atPath: path)!, encoding: .utf8), """
        newww text
        second line
        
        """)
        
        secondStream.truncateRemaining()
        
        XCTAssertEqual(String(data: FileManager.default.contents(atPath: path)!, encoding: .utf8), """
        newww text
        """)
    }
    
}
