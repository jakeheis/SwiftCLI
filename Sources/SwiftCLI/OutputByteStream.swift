//
//  OutputByteStream.swift
//  SwiftCLI
//
//  Created by Jake Heiser on 9/11/17.
//

import Foundation

public protocol OutputByteStream {
    func output(_ content: String)
}

public class StdoutStream: OutputByteStream {
    public init() {}
    public func output(_ content: String) {
        print(content)
    }
}

public class StderrStream: OutputByteStream {
    public init() {}
    public func output(_ content: String) {
        printError(content)
    }
}

public class NullStream: OutputByteStream {
    public init() {}
    public func output(_ content: String) {}
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
    public func output(_ content: String) {
        guard let data = (content + "\n").data(using: .utf8) else {
            fatalError("Couldn't output content: \(content)")
        }
        handle.write(data)
    }
    deinit {
        handle.closeFile()
    }
}

public class CaptureStream: OutputByteStream {
    private(set) var content: String = ""
    public init() {}
    public func output(_ content: String) {
        self.content += content + "\n"
    }
}

public func <<(stream: OutputByteStream, text: String) {
    stream.output(text)
}
