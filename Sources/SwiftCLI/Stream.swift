//
//  OutputByteStream.swift
//  SwiftCLI
//
//  Created by Jake Heiser on 9/11/17.
//

import Foundation
import Dispatch

open class WriteStream {
    
    public static let stdout = WriteStream(fileHandle: .standardOutput)
    public static let stderr = WriteStream(fileHandle: .standardError)
    public static let null = WriteStream(fileHandle: .nullDevice)
    
    let fileHandle: FileHandle
    
    public init(fileHandle: FileHandle) {
        self.fileHandle = fileHandle
    }
    
    public convenience init?(path: String) {
        guard let fileHandle = FileHandle(forWritingAtPath: path) else {
            return nil
        }
        fileHandle.seekToEndOfFile()
        self.init(fileHandle: fileHandle)
    }
    
    public func write(_ content: String) {
        guard let data = content.data(using: .utf8) else {
            fatalError("Couldn't write content: \(content)")
        }
        fileHandle.write(data)
    }
    
    public func print(_ content: String, terminator: String = "\n") {
        write(content + terminator)
    }
    
    public func close() {
        fileHandle.closeFile()
    }
    
}

public class CaptureStream: WriteStream {
    
    private var content: String = ""
    private let inStream: ReadStream
    private let semaphore = DispatchSemaphore(value: 0)
    
    public init() {
        let pipe = Pipe()
        self.inStream = ReadStream(fileHandle: pipe.fileHandleForReading)
        super.init(fileHandle: pipe.fileHandleForWriting)
        
        DispatchQueue.global().async { [weak self] in
            if let content = self?.inStream.readAll() {
                self?.content = content
            }
            self?.semaphore.signal()
        }
    }
    
    public func awaitContent() -> String {
        semaphore.wait()
        return content
    }
    
}

public class ReadStream {
    
    public static let stdin = ReadStream(fileHandle: .standardInput)
    
    let fileHandle: FileHandle
    private var carryData: Data? = nil
    
    public init(fileHandle: FileHandle) {
        self.fileHandle = fileHandle
    }
    
    public convenience init?(path: String) {
        guard let fileHandle = FileHandle(forReadingAtPath: path) else {
            return nil
        }
        self.init(fileHandle: fileHandle)
    }
    
    public func read() -> String? {
        let data = (carryData ?? Data()) + fileHandle.availableData
        guard !data.isEmpty else { return nil }
        
        return String(data: data, encoding: .utf8)
    }
    
    public func readLine() -> String? {
        var accumluated = carryData ?? Data()
        
        let delimiter = "\n".data(using: .utf8)![0]
        while !accumluated.contains(delimiter) {
            let data = fileHandle.readData(ofLength: 10)
            if data.isEmpty {
                if accumluated.isEmpty {
                    return nil
                }
                break
            }
            accumluated += data
        }
        
        let lineData: Data
        if let index = accumluated.index(of: delimiter) {
            lineData = accumluated[..<index]
            let remainder = accumluated[accumluated.index(after: index)...]
            carryData = remainder.isEmpty ? nil : remainder
        } else {
            lineData = accumluated
            carryData = nil
        }
        
        return String(data: lineData, encoding: .utf8)
    }
    
    public func readLines() -> LazySequence<AnyIterator<String>> {
        let iter = AnyIterator {
            return self.readLine()
        }
        return iter.lazy
    }
    
    public func readAll() -> String {
        var all = ""
        while let some = read() {
            all += some
        }
        return all
    }
    
    public func forward(to output: WriteStream) {
        DispatchQueue.global().async { [weak self] in
            while let some = self?.read() {
                output.write(some)
            }
        }
    }
    
    public func close() {
        fileHandle.closeFile()
    }
    
}

// MARK: -

infix operator <<<: AssignmentPrecedence

public func <<<(stream: WriteStream, text: String) {
    stream.print(text)
}
