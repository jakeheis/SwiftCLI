//
//  OutputByteStream.swift
//  SwiftCLI
//
//  Created by Jake Heiser on 9/11/17.
//

import Foundation

// MARK: - Writable

public protocol WritableStream {
    var writeStream: WriteStream { get }
    var encoding: String.Encoding { get }
    var processObject: Any { get }
}

extension WritableStream {
    
    public func write(_ content: String) {
        guard let data = content.data(using: encoding) else {
            fatalError("Couldn't write content: \(content)")
        }
        writeStream.writeHandle.write(data)
    }
    
    public func print(_ content: String, terminator: String = "\n") {
        write(content + terminator)
    }
    
    public func closeWrite() {
        writeStream.writeHandle.closeFile()
    }
    
}

public class WriteStream: WritableStream {
    
    public static let stdout = WriteStream(writeHandle: .standardOutput)
    public static let stderr = WriteStream(writeHandle: .standardError)
    public static let null = WriteStream(writeHandle: .nullDevice)
    
    fileprivate let writeHandle: FileHandle
    
    // WritableStream
    public var writeStream: WriteStream { return self }
    public var encoding: String.Encoding = .utf8
    public var processObject: Any { return writeHandle }
    
    public init(writeHandle: FileHandle) {
        self.writeHandle = writeHandle
    }
    
    public convenience init?(path: String) {
        guard let fileHandle = FileHandle(forWritingAtPath: path) else {
            return nil
        }
        fileHandle.seekToEndOfFile()
        self.init(writeHandle: fileHandle)
    }
    
    public func close() {
        closeWrite()
    }
    
}

// MARK: - Readable

public protocol ReadableStream: class {
    var readStream: ReadStream { get }
    var encoding: String.Encoding { get }
    var processObject: Any { get }
}

extension ReadableStream {
    
    public func readData() -> Data? {
        let data = readStream.readHandle.availableData
        return data.isEmpty ? nil : data
    }
    
    public func read() -> String? {
        let unread = readStream.unreadBuffer
        readStream.unreadBuffer = ""
        
        guard let data = readData() else {
            return unread.isEmpty ? nil : unread
        }
        guard let new = String(data: data, encoding: encoding) else {
            fatalError("Couldn't parse data into string using \(encoding)")
        }
        return unread + new
    }
    
    public func readLine(delimiter: Character = "\n") -> String? {
        guard var accumluated = read() else {
            return nil
        }
        
        while !accumluated.contains(delimiter) {
            if let some = read() {
                accumluated += some
            } else {
                break
            }
        }
        
        if let index = accumluated.index(of: delimiter) {
            let remainder = String(accumluated[accumluated.index(after: index)...])
            readStream.unreadBuffer = remainder.isEmpty ? "" : remainder
            return String(accumluated[..<index])
        } else {
            return accumluated
        }
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
    
    public func closeRead() {
        readStream.readHandle.closeFile()
    }
    
}

public class ReadStream: ReadableStream {
    
    public static let stdin = ReadStream(readHandle: .standardInput)
    
    fileprivate let readHandle: FileHandle
    fileprivate var unreadBuffer = ""
    
    // ReadableStream
    public var readStream: ReadStream { return self }
    public var encoding: String.Encoding = .utf8
    public var processObject: Any { return readHandle }
    
    public init(readHandle: FileHandle) {
        self.readHandle = readHandle
    }
    
    public convenience init?(path: String) {
        guard let readHandle = FileHandle(forReadingAtPath: path) else {
            return nil
        }
        self.init(readHandle: readHandle)
    }
    
    public func close() {
        closeRead()
    }
    
}

// MARK: - Pipe

public class PipeStream: ReadableStream, WritableStream {
    
    public let processObject: Any
    public let readStream: ReadStream
    public let writeStream: WriteStream
    public var encoding: String.Encoding {
        get {
            return readStream.encoding
        }
        set(newValue) {
            readStream.encoding = newValue
            writeStream.encoding = newValue
        }
    }
    
    public init() {
        let pipe = Pipe()
        self.processObject = pipe
        self.readStream = ReadStream(readHandle: pipe.fileHandleForReading)
        self.writeStream = WriteStream(writeHandle: pipe.fileHandleForWriting)
    }
    
}

// MARK: -

infix operator <<<: AssignmentPrecedence

public func <<<(stream: WritableStream, text: String) {
    stream.print(text)
}
