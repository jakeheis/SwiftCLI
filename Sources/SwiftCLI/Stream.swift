//
//  Stream.swift
//  SwiftCLI
//
//  Created by Jake Heiser on 9/11/17.
//

import Dispatch
import Foundation

// MARK: - WritableStream

public protocol WritableStream: class {
    var writeHandle: FileHandle { get }
    var processObject: Any { get }
    var encoding: String.Encoding { get }
}

extension WritableStream {
    
    /// Writes the given data to the stream
    ///
    /// - Parameter data: the data to write
    public func writeData(_ data: Data) {
        writeHandle.write(data)
    }
    
    /// Write the given content to the stream without any terminator
    ///
    /// - Parameter content: the content to write
    public func write(_ content: String) {
        guard let data = content.data(using: encoding) else {
            assertionFailure("Couldn't write content: \(content)")
            return
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
        writeHandle.closeFile()
    }
    
}

public enum WriteStream {
    
    /// A stream which writes to the current process's standard output
    public static let stdout: WritableStream = WriteStream.for(fileHandle: .standardOutput)
    
    /// A stream which writes to the current process's standard error
    public static let stderr: WritableStream = WriteStream.for(fileHandle: .standardError)
    
    /// A stream which does nothing upon write
    public static let null: WritableStream = WriteStream.for(path: "/dev/null")!
    
    /// Create a stream which writes to the given path
    ///
    /// - Parameters:
    ///   - path: the path to write to
    ///   - appending: whether written data should be appended to the end of the file if the file already exists; default true
    /// - Returns: a new FileStream if the path exists and can be written to
    public static func `for`(path: String, appending: Bool = true) -> FileStream? {
        return FileStream(path: path, appending: appending)
    }
    
    /// Create a stream which writes to the given file handle
    ///
    /// - Parameter fileHandle: the file handle to write to
    /// - Returns: a new FileHandleStream
    public static func `for`(fileHandle: FileHandle) -> FileHandleStream {
        return FileHandleStream(writeHandle: fileHandle)
    }
    
    /// Create a stream which writes to the given file descriptor
    ///
    /// - Parameter fileDescriptor: the file descriptor to write to
    /// - Returns: a new FileHandleStream
    public static func `for`(fileDescriptor: Int32) -> FileHandleStream {
        return FileHandleStream(writeHandle: FileHandle(fileDescriptor: fileDescriptor))
    }
    
    public class FileStream: WritableStream {
        
        public let writeHandle: FileHandle
        public let processObject: Any
        public let encoding: String.Encoding
        
        /// The position of the file pointer within the file
        public var offset: UInt64 {
            return writeHandle.offsetInFile
        }
        
        /// Create a stream which writes to the given path
        ///
        /// - Parameters:
        ///   - path: the path to write to
        ///   - appending: whether written data should be appended to the end of the file if the file already exists; default true
        ///   - encoding: the encoding with which to write strings; default .utf8
        public init?(path: String, appending: Bool = true, createIfNecessary: Bool = true, encoding: String.Encoding = .utf8) {
            let path = NSString(string: path).expandingTildeInPath
            if !FileManager.default.fileExists(atPath: path) && createIfNecessary {
                guard FileManager.default.createFile(atPath: path, contents: nil, attributes: nil) else {
                    return nil
                }
            }
            guard let fileHandle = FileHandle(forWritingAtPath: path) else {
                return nil
            }
            if appending {
                fileHandle.seekToEndOfFile()
            }
            self.writeHandle = fileHandle
            self.processObject = fileHandle
            self.encoding = encoding
        }
        
        /// Create a file stream from the given file handle stream
        ///
        /// - Parameter stream: the file handle stream to convert to a file stream
        /// - Warning: This init should only be used if it is guaranteed that the file handle wrapped by the FileHandleStream is backed by a file,
        ///            not a pipe or a socket
        public init(unsafeFileHandleStream stream: FileHandleStream) {
            self.writeHandle = stream.writeHandle
            self.processObject = stream.processObject
            self.encoding = stream.encoding
        }
        
        /// Moves the file pointer to the specified offset within the file
        ///
        /// - Parameter offset: the offset to seek to
        public func seek(to offset: UInt64) {
            writeHandle.seek(toFileOffset: offset)
        }
        
        /// Puts the file pointer at the end of the file referenced by the receiver
        public func seekToEnd() {
            writeHandle.seekToEndOfFile()
        }
        
        /// Truncate the file represented by this stream after the given byte offset
        ///
        /// - Parameter offset: the byte offset after which to truncate
        public func truncate(at offset: UInt64) {
            // Use C func rather than writeHandle.truncateFile due to the latter not working on Linux
            ftruncate(writeHandle.fileDescriptor, off_t(offset))
        }
        
        /// Truncate the file represented by this stream after the current byte offset
        public func truncateRemaining() {
            truncate(at: offset)
            writeHandle.synchronizeFile()
        }
        
    }
    
    public class FileHandleStream: WritableStream {
        
        public let writeHandle: FileHandle
        public let processObject: Any
        public let encoding: String.Encoding
        
        /// Create a stream which writes to the given file handle
        ///
        /// - Parameter writeHandle: the file handle to write to
        public init(writeHandle: FileHandle, encoding: String.Encoding = .utf8) {
            self.writeHandle = writeHandle
            self.processObject = writeHandle
            self.encoding = encoding
        }
        
    }
    
}

// MARK: - Readable

public protocol ReadableStream: class {
    var readHandle: FileHandle { get }
    var processObject: Any { get }
    var encoding: String.Encoding { get }
    var readBuffer: ReadBuffer { get }
}

extension ReadableStream {
    
    /// Read any available data; blocks if no data is available but stream is open
    ///
    /// - Returns: the read data
    public func readData() -> Data? {
        let data = readHandle.availableData
        return data.isEmpty ? nil : data
    }
    
    /// Read any available text; blocks if no text is available but stream is open
    ///
    /// - Returns: the read text
    public func read() -> String? {
        let unread = readBuffer.clear()
        
        guard let data = readData() else {
            return unread.isEmpty ? nil : unread
        }
        guard let new = String(data: data, encoding: encoding) else {
            assertionFailure("Couldn't parse data into string using \(encoding)")
            return nil
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
        
        if let index = accumluated.firstIndex(of: delimiter) {
            let remainder = String(accumluated[accumluated.index(after: index)...])
            readBuffer.fill(with: remainder)
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
        readHandle.closeFile()
    }
    
}

public class ReadBuffer {
    
    private var buffer = ""
    
    public init() {}
    
    fileprivate func fill(with content: String) {
        buffer = content
    }
    
    @discardableResult
    fileprivate func clear() -> String {
        defer { buffer = "" }
        return buffer
    }
    
}

public enum ReadStream {
    
    /// A stream which reads from the current process's standard input
    /// - Warning: do not call readLine on this stream and also call Swift.readLine() or Input.readLine()
    public static let stdin: ReadableStream = FileHandleStream(readHandle: .standardInput)
    
    /// Create a new FileStream for the given path
    ///
    /// - Parameter path: the path which should be read from
    /// - Returns: a new FileStream if the file exists and is readable
    public static func `for`(path: String) -> FileStream? {
        return FileStream(path: path)
    }
    
    /// Create a new FileHandleStream for the given file handle
    ///
    /// - Parameter fileHandle: a file handle which can be read from
    /// - Returns: a new FileHandleStream
    public static func `for`(fileHandle: FileHandle) -> FileHandleStream {
        return FileHandleStream(readHandle: fileHandle)
    }
    
    /// Create a new FileHandleStream for the given file descriptor
    ///
    /// - Parameter fileDescriptor: a file descriptor which can be read from
    /// - Returns: a new FileHandleStream
    public static func `for`(fileDescriptor: Int32) -> FileHandleStream {
        return FileHandleStream(readHandle: FileHandle(fileDescriptor: fileDescriptor))
    }
    
    public class FileStream: ReadableStream {
        
        public let readHandle: FileHandle
        public let processObject: Any
        public let encoding: String.Encoding
        public let readBuffer = ReadBuffer()
        
        /// The position of the file pointer within the file
        public var offset: UInt64 {
            return readHandle.offsetInFile
        }
        
        /// Create a stream which reads from the given path
        ///
        /// - Parameters:
        ///   - path: the path to read from
        ///   - encoding: the encoding with which to read data; default .utf8
        public init?(path: String, encoding: String.Encoding = .utf8) {
            let path = NSString(string: path).expandingTildeInPath
            guard let readHandle = FileHandle(forReadingAtPath: path) else {
                return nil
            }
            self.readHandle = readHandle
            self.processObject = readHandle
            self.encoding = encoding
        }
        
        /// Moves the file pointer to the specified offset within the file
        ///
        /// - Parameter offset: the offset to seek to
        public func seek(to offset: UInt64) {
            readHandle.seek(toFileOffset: offset)
            readBuffer.clear()
        }
        
        /// Puts the file pointer at the end of the file referenced by the receiver
        public func seekToEnd() {
            readHandle.seekToEndOfFile()
            readBuffer.clear()
        }
        
    }
    
    public class FileHandleStream: ReadableStream {
        
        public let readHandle: FileHandle
        public let processObject: Any
        public let encoding: String.Encoding
        public let readBuffer = ReadBuffer()
        
        /// Create a stream which reads from the given file handle
        ///
        /// - Parameters:
        ///   - readHandle: the file handle to read from
        ///   - encoding: the encoding with which to read data; default .utf8
        public init(readHandle: FileHandle, encoding: String.Encoding = .utf8) {
            self.readHandle = readHandle
            self.processObject = readHandle
            self.encoding = encoding
        }
        
    }
    
}

// MARK: - Pipe based streams

public class PipeStream: ReadableStream, WritableStream {
    
    public let readHandle: FileHandle
    public let writeHandle: FileHandle
    public let processObject: Any
    public var encoding: String.Encoding = .utf8
    public let readBuffer = ReadBuffer()
    
    /// Creates a new pipe stream
    public init() {
        let pipe = Pipe()
        self.processObject = pipe
        self.readHandle = pipe.fileHandleForReading
        self.writeHandle = pipe.fileHandleForWriting
    }
    
}

public protocol ProcessingStream: WritableStream {
    /// Blocks until this stream has completed processing its input
    func waitToFinishProcessing()
}

public class LineStream: ProcessingStream {
    
    public let writeHandle: FileHandle
    public let processObject: Any
    public var encoding: String.Encoding = .utf8
    
    private let queue = DispatchQueue(label: "com.jakeheis.SwiftCLI.LineStream")
    private let semaphore = DispatchSemaphore(value: 0)
    
    /// Creates a new stream which can be written to
    ///
    /// - Parameter each: called every time a line of text is written to the stream
    public init(each: @escaping (String) -> ()) {
        let pipe = Pipe()
        self.processObject = pipe
        self.writeHandle = pipe.fileHandleForWriting
        
        let readStream = ReadStream.for(fileHandle: pipe.fileHandleForReading)
        queue.async { [weak self] in
            while let line = readStream.readLine() {
                each(line)
            }
            self?.semaphore.signal()
        }
    }
    
    /// Wait for the line stream to call the 'each' closure on every line of text until it reaches EOF;
    /// should not be called directly if the stream is the stdout or stderr of a Task
    public func waitToFinishProcessing() {
        semaphore.wait()
    }
    
}

public class CaptureStream: ProcessingStream {
    
    public let processObject: Any
    public let writeHandle: FileHandle
    public var encoding: String.Encoding = .utf8
    
    private var content = Data()
    private let queue = DispatchQueue(label: "com.jakeheis.SwiftCLI.CaptureStream")
    private let semaphore = DispatchSemaphore(value: 0)
    private var waited = false
    
    /// Creates a new stream which collects all data written to it
    ///
    /// - Parameter each: called every time a chunk of data is written to the stream
    public init(each: ((Data) -> ())? = nil) {
        let pipe = Pipe()
        self.processObject = pipe
        self.writeHandle = pipe.fileHandleForWriting
        
        let readStream = ReadStream.for(fileHandle: pipe.fileHandleForReading)
        queue.async { [weak self] in
            while let chunk = readStream.readData() {
                self?.content += chunk
                each?(chunk)
            }
            self?.semaphore.signal()
        }
    }
    
    /// Blocks until all output has been captured; should not be called directly if the stream is the stdout or stderr of a Task
    public func waitToFinishProcessing() {
        waited = true
        semaphore.wait()
    }
    
    /// Read all the data written to this stream as Data; blocks until all output has been captured
    ///
    /// - Returns: all captured data
    public func readAllData() -> Data {
        if !waited {
            waitToFinishProcessing()
        }
        return content
    }
    
    /// Read all the data written to this stream as a String; blocks until all output has been captured
    ///
    /// - Returns: all captured data
    public func readAll() -> String {
        return String(data: readAllData(), encoding: encoding) ?? ""
    }
    
}

// MARK: -

infix operator <<<: AssignmentPrecedence

public func <<<(stream: WritableStream, text: String) {
    stream.print(text)
}
