//
//  Stream.swift
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
    
    /// Writes the given data to the stream
    ///
    /// - Parameter data: the data to write
    public func writeData(_ data: Data) {
        writeStream.writeHandle.write(data)
    }
    
    /// Write the given content to the stream without any terminator
    ///
    /// - Parameter content: the content to write
    public func write(_ content: String) {
        guard let data = content.data(using: encoding) else {
            fatalError("Couldn't write content: \(content)")
        }
        writeData(data)
    }
    
    /// Write the given content to the stream with a terminator (default newline)
    ///
    /// - Parameters:
    ///   - content: the content to write
    ///   - terminator: the terminator to write after the content; default newline
    public func print(_ content: String, terminator: String = "\n") {
        write(content + terminator)
    }
    
    /// Close the stream
    public func closeWrite() {
        writeStream.writeHandle.closeFile()
    }
    
}

public class WriteStream: WritableStream {
    
    /// A stream which writes to the current process's standard output
    public static let stdout = WriteStream(writeHandle: .standardOutput)
    
    /// A stream which writes to the current process's standard error
    public static let stderr = WriteStream(writeHandle: .standardError)
    
    /// A stream which does nothing upon write
    public static let null = WriteStream(writeHandle: .nullDevice)
    
    // WritableStream
    public var writeStream: WriteStream { return self }
    public var encoding: String.Encoding = .utf8
    public var processObject: Any { return writeHandle }
    
    // private
    fileprivate let writeHandle: FileHandle
    
    /// Create a stream which writes to the given file handle
    ///
    /// - Parameter writeHandle: the file handle to write to
    public init(writeHandle: FileHandle) {
        self.writeHandle = writeHandle
    }
    
    /// Create a stream which writes to the given path
    ///
    /// - Parameter path: the path to write to
    public convenience init?(path: String) {
        guard let fileHandle = FileHandle(forWritingAtPath: path) else {
            return nil
        }
        fileHandle.seekToEndOfFile()
        self.init(writeHandle: fileHandle)
    }
    
    /// Close the stream
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
    
    /// Read any available data; blocks if no data is available but stream is open
    ///
    /// - Returns: the read data
    public func readData() -> Data? {
        let data = readStream.readHandle.availableData
        return data.isEmpty ? nil : data
    }
    
    /// Read any available text; blocks if no text is available but stream is open
    ///
    /// - Returns: the read text
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
    
    /// Read a line of text ending with the given delimiter; blocks if line of text is not available but stream is open
    ///
    /// - Parameter delimiter: the end of line marker; default newline
    /// - Returns: the line of text
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
    
    /// Lazily read a seuqence of all lines
    ///
    /// - Returns: a lazy sequence of all lines
    public func readLines() -> LazySequence<AnyIterator<String>> {
        let iter = AnyIterator {
            return self.readLine()
        }
        return iter.lazy
    }
    
    /// Read all content; blocks until stream is closed
    ///
    /// - Returns: all content
    public func readAll() -> String {
        var all = ""
        while let some = read() {
            all += some
        }
        return all
    }
    
    /// Close the stream
    public func closeRead() {
        readStream.readHandle.closeFile()
    }
    
}

public class ReadStream: ReadableStream {
    
    /// A stream which reads from the current process's standard input
    /// - Warning: do not call readLine on this stream and also call Swift.readLine() or Input.readLine()
    public static let stdin = ReadStream(readHandle: .standardInput)
    
    fileprivate let readHandle: FileHandle
    fileprivate var unreadBuffer = ""
    
    // ReadableStream
    public var readStream: ReadStream { return self }
    public var encoding: String.Encoding = .utf8
    public var processObject: Any { return readHandle }
    
    /// Create a stream which reads from the given file handle
    ///
    /// - Parameter path: the file handle to read from
    public init(readHandle: FileHandle) {
        self.readHandle = readHandle
    }
    
    /// Create a stream which reads from the given path
    ///
    /// - Parameter path: the path to read from
    public convenience init?(path: String) {
        guard let readHandle = FileHandle(forReadingAtPath: path) else {
            return nil
        }
        self.init(readHandle: readHandle)
    }
    
    /// Close the stream
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
