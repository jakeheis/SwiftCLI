//
//  OutputByteStream.swift
//  SwiftCLI
//
//  Created by Jake Heiser on 9/11/17.
//

import Foundation

public protocol OutputByteStream {
    func output(_ content: String, terminator: String)
}

public extension OutputByteStream {
    func output(_ content: String) {
        output(content, terminator: "\n")
    }
}

public class StdoutStream: OutputByteStream {
    public init() {}
    public func output(_ content: String, terminator: String) {
        print(content, terminator: terminator)
        fflush(stdout)
    }
}

public class StderrStream: OutputByteStream {
    public init() {}
    public func output(_ content: String, terminator: String) {
        printError(content, terminator: terminator)
    }
}

public class NullStream: OutputByteStream {
    public init() {}
    public func output(_ content: String, terminator: String) {}
}

public class FileStream: OutputByteStream {
    let handle: FileHandle
    public init?(path: String) {
        guard let handle = FileHandle(forWritingAtPath: path) else {
            return nil
        }
        handle.seekToEndOfFile()
        self.handle = handle
    }
    public func output(_ content: String, terminator: String) {
        guard let data = (content + terminator).data(using: .utf8) else {
            fatalError("Couldn't output content: \(content)")
        }
        handle.write(data)
    }
    deinit {
        handle.closeFile()
    }
}

public class CaptureStream: OutputByteStream {
    public private(set) var content: String = ""
    public init() {}
    public func output(_ content: String, terminator: String) {
        self.content += content + terminator
    }
}

infix operator <<<: AssignmentPrecedence

public func <<<(stream: OutputByteStream, text: String) {
    stream.output(text)
}
