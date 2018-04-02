//
//  OutputByteStream.swift
//  SwiftCLI
//
//  Created by Jake Heiser on 9/11/17.
//

import Foundation
import Dispatch

public class OutStream {
    
    public static let stdout = OutStream(fileHandle: FileHandle.standardOutput)
    public static let stderr = OutStream(fileHandle: FileHandle.standardError)
    public static let null = OutStream(fileHandle: FileHandle.nullDevice)
    
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

public class CaptureStream: OutStream {
    
    public private(set) var content: String = ""
    private let inStream: InStream
    
    private let semaphore = DispatchSemaphore(value: 0)
    
    public init() {
        let pipe = Pipe()
        self.inStream = InStream(fileHandle: pipe.fileHandleForReading)
        super.init(fileHandle: pipe.fileHandleForWriting)
        
        DispatchQueue.global().async { [weak self] in
            while let some = self?.inStream.read() {
                self?.content += some
            }
            self?.semaphore.signal()
        }
    }
    
    public func finish() {
        close()
        semaphore.wait()
    }
    
}

public class InStream {
    
    public static let stdin = InStream(fileHandle: FileHandle.standardInput)
    
    let fileHandle: FileHandle
    
    var onInput: ((String) -> ())? {
        didSet {
            fileHandle.readabilityHandler = { [weak self] (handle) in
                guard let str = String(data: handle.availableData, encoding: .utf8) else {
                    fatalError()
                }
                self?.onInput?(str)
            }
        }
    }
    
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
        let data = fileHandle.availableData
        guard !data.isEmpty else { return nil }
        
        return String(data: data, encoding: .utf8)
    }
    
    public func readAll() -> String {
        var all = ""
        while let some = read() {
            all += some
        }
        return all
    }
    
    public func forward(to output: OutStream) {
        DispatchQueue.global().async { [weak self] in
            while let some = self?.read() {
                output.write(some)
            }
        }
    }
    
}

// MARK: -

infix operator <<<: AssignmentPrecedence

public func <<<(stream: OutStream, text: String) {
    stream.print(text)
}
