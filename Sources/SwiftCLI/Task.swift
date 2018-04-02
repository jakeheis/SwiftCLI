//
//  Task.swift
//  SwiftCLI
//
//  Created by Jake Heiser on 4/1/18.
//

import Foundation

// MARK: -

public func execute(_ executable: String, _ args: String...) throws {
    let task = Task(executable: executable, args: args)
    let code = task.runSync()
    guard code == 0 else {
        throw ExecuteError(code: code)
    }
}

public func capture(_ executable: String, _ args: String...) throws -> CaptureResult {
    let out = CaptureStream()
    let err = CaptureStream()
    
    let task = Task(executable: executable, args: args, stdout: out, stderr: err)
    let exitCode = task.runSync()
    out.finish()
    err.finish()
    
    let captured = CaptureResult(rawStdout: out.content, rawStderr: err.content)
    guard exitCode == 0 else {
        throw CaptureError(code: exitCode, captured: captured)
    }
    
    return captured
}

public func execute(bash: String) throws {
    try execute("/bin/bash", "-c", bash)
}

public func capture(bash: String) throws -> CaptureResult {
    return try capture("/bin/bash", "-c", bash)
}

// MARK: -

public class Task {
    
    private let process: Process
    public var onTermination: ((Int32) -> ())? = nil
    
    public init(executable: String, args: [String] = [], stdout: WriteStream = .stdout, stderr: WriteStream = .stderr, stdin: ReadStream = .stdin, forwardInterrupt: Bool = true) {
        self.process = Process()
        self.process.launchPath = Task.findExecutable(named: executable) ?? executable
        self.process.arguments = args
        
        if forwardInterrupt {
            InterruptPasser.add(self)
        }
        
        self.process.terminationHandler = { [weak self] (process) in
            guard let weakSelf = self else { return }
            if forwardInterrupt {
                InterruptPasser.remove(weakSelf)
            }
            weakSelf.onTermination?(process.terminationStatus)
        }
        
        if stdout !== WriteStream.stdout {
            self.process.standardOutput = stdout.fileHandle
        }
        if stderr !== WriteStream.stderr {
            self.process.standardError = stderr.fileHandle
        }
        if stdin !== ReadStream.stdin {
            self.process.standardInput = stdin.fileHandle
        }
    }
    
    public func runSync() -> Int32 {
        process.launch()
        return finish()
    }
    
    public func runAsync() {
        process.launch()
    }
    
    public func finish() -> Int32 {
        process.waitUntilExit()
        return process.terminationStatus
    }
    
    public func interrupt() {
        process.interrupt()
    }
    
}

// MARK: -

extension Task {
    public static func createPipe() -> (read: ReadStream, write: WriteStream) {
        let pipe = Pipe()
        return (ReadStream(fileHandle: pipe.fileHandleForReading), WriteStream(fileHandle: pipe.fileHandleForWriting))
    }
    
    public static func findExecutable(named: String) -> String? {
        if named.hasPrefix("/") || named.hasPrefix(".") {
            return named
        }
        return try? capture(bash: "which \(named)").stdout
    }
}

struct ExecuteError: Swift.Error {
    let code: Int32
}

struct CaptureError: Swift.Error {
    let code: Int32
    let captured: CaptureResult
}

public struct CaptureResult {
    public let rawStdout: String
    public let rawStderr: String
    
    public var stdout: String {
        return rawStdout.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    public var stderr: String {
        return rawStderr.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

// MARK: - Interrupts

private class InterruptPasser {
    
    private static var lock = NSLock()
    private static var hasBeenSetup = false
    private static var tasks: [ObjectIdentifier: Task] = [:]
    
    private static func setup() {
        if hasBeenSetup { return }
        
        signal(SIGINT) { (sig) in
            InterruptPasser.interrupt()
            
            signal(SIGINT, SIG_DFL)
            raise(SIGINT)
        }
        
        hasBeenSetup = true
    }
    
    private static func interrupt() {
        for task in tasks.values {
            task.interrupt()
        }
    }
    
    static func add(_ task: Task) {
        lock.lock()
        setup()
        tasks[ObjectIdentifier(task)] = task
        lock.unlock()
    }
    
    static func remove(_ task: Task) {
        lock.lock()
        tasks[ObjectIdentifier(task)] = nil
        lock.unlock()
    }
    
}
