//
//  OutputByteStream.swift
//  SwiftCLI
//
//  Created by Jake Heiser on 9/11/17.
//

import Foundation
import Dispatch

public protocol WritableStream {
    var writeHandle: FileHandle { get }
    var encoding: String.Encoding { get }
    var processObject: Any { get }
}

extension WritableStream {
    public func write(_ content: String) {
        guard let data = content.data(using: encoding) else {
            fatalError("Couldn't write content: \(content)")
        }
        writeHandle.write(data)
    }
    
    public func print(_ content: String, terminator: String = "\n") {
        write(content + terminator)
    }
    
    public func closeWrite() {
        writeHandle.closeFile()
    }
}

public class WriteStream: WritableStream {
    
    public static let stdout = WriteStream(writeHandle: .standardOutput)
    public static let stderr = WriteStream(writeHandle: .standardError)
    public static let null = WriteStream(writeHandle: .nullDevice)
    
    public let writeHandle: FileHandle
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

public protocol ReadableStream: class {
    var readHandle: FileHandle { get }
    var unreadBuffer: String { get set }
    var encoding: String.Encoding { get }
    var processObject: Any { get }
}

extension ReadableStream {
    public func readData() -> Data? {
        let data = readHandle.availableData
        return data.isEmpty ? nil : data
    }
    
    public func read() -> String? {
        let unread = unreadBuffer
        unreadBuffer = ""
        
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
            unreadBuffer = remainder.isEmpty ? "" : remainder
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
    
    public func forward(to output: WriteStream) {
        DispatchQueue.global().async { [weak self] in
            while let some = self?.read() {
                output.write(some)
            }
        }
    }
    
    public func closeRead() {
        readHandle.closeFile()
    }
}

public class ReadStream: ReadableStream {
    
    public static let stdin = ReadStream(readHandle: .standardInput)
    
    public let readHandle: FileHandle
    public var unreadBuffer = ""
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

public class PipeStream: ReadableStream, WritableStream {
    
    public let pipe: Pipe
    
    let readStream: ReadStream
    let writeStream: WriteStream
    
    public var readHandle: FileHandle { return readStream.readHandle }
    public var writeHandle: FileHandle { return writeStream.writeHandle }
    public var encoding: String.Encoding = .utf8
    public var processObject: Any { return pipe }
    
    public var unreadBuffer: String {
        get {
            return readStream.unreadBuffer
        }
        set(newValue) {
            readStream.unreadBuffer = newValue
        }
    }
    
    public init() {
        self.pipe = Pipe()
        self.readStream = ReadStream(readHandle: pipe.fileHandleForReading)
        self.writeStream = WriteStream(writeHandle: pipe.fileHandleForWriting)
    }
    
}

// MARK: -

infix operator <<<: AssignmentPrecedence

public func <<<(stream: WritableStream, text: String) {
    stream.print(text)
}
