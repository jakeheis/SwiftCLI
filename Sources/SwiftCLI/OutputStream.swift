//
//  OutputStream.swift
//  SwiftCLI
//
//  Created by Jake Heiser on 9/11/17.
//

public protocol OutputStream {
    func output(_ content: String)
}

public class StdoutStream: OutputStream {
    public init() {}
    public func output(_ content: String) {
        print(content)
    }
}

public class StderrStream: OutputStream {
    public init() {}
    public func output(_ content: String) {
        printError(content)
    }
}

public class NullStream: OutputStream {
    public init() {}
    public func output(_ content: String) {}
}

public class CaptureStream: OutputStream {
    private(set) var content: String = ""
    public init() {}
    public func output(_ content: String) {
        self.content += content + "\n"
    }
}

infix operator <<

public func <<(stream: OutputStream, text: String) {
    stream.output(text)
}
