//
//  Task.swift
//  SwiftCLI
//
//  Created by Jake Heiser on 4/1/18.
//

import Foundation

// MARK: -

public func run(_ executable: String, _ args: String...) throws {
    try run(executable, args)
}

public func run(_ executable: String, _ args: [String]) throws {
    let task = Task(executable: executable, args: args)
    let code = task.runSync()
    guard code == 0 else {
        throw ExecuteError(exitStatus: code)
    }
}

public func capture(_ executable: String, _ args: String...) throws -> CaptureResult {
    return try capture(executable, args)
}

public func capture(_ executable: String, _ args: [String]) throws -> CaptureResult {
    let out = PipeStream()
    let err = PipeStream()
    
    let task = Task(executable: executable, args: args, stdout: out, stderr: err)
    let exitCode = task.runSync()
    
    let captured = CaptureResult(rawStdout: out.readAll(), rawStderr: err.readAll())
    guard exitCode == 0 else {
        throw CaptureError(exitStatus: exitCode, captured: captured)
    }
    
    return captured
}

public func run(bash: String) throws {
    try run("/bin/bash", "-c", bash)
}

public func capture(bash: String) throws -> CaptureResult {
    return try capture("/bin/bash", "-c", bash)
}

// MARK: -

public class Task {
    
    public static func findExecutable(named: String) -> String? {
        if named.hasPrefix("/") || named.hasPrefix(".") {
            return named
        }
        return try? capture(bash: "which \(named)").stdout
    }
    
    private let process: Process
    
    public var onTermination: ((Int32) -> ())? = nil
    public var env: [String: String] = ProcessInfo.processInfo.environment
    public var forwardInterrupt = true
    
    private var stdout: WritableStream?
    private var stderr: WritableStream?
    private var stdin: ReadableStream?
    
    public init(executable: String, args: [String] = [], currentDirectory: String? = nil, stdout: WritableStream = WriteStream.stdout, stderr: WritableStream = WriteStream.stderr, stdin: ReadableStream = ReadStream.stdin) {
        self.process = Process()
        self.process.launchPath = Task.findExecutable(named: executable) ?? executable
        self.process.arguments = args
        if let currentDirectory = currentDirectory {
            self.process.currentDirectoryPath = currentDirectory
        }
        
        if (stdout as? WriteStream) !== WriteStream.stdout {
            self.process.standardOutput = stdout.processObject
            self.stdout = stdout
        }
        if (stderr as? WriteStream) !== WriteStream.stderr {
            self.process.standardError = stderr.processObject
            self.stderr = stderr
        }
        if (stdin as? ReadStream) !== ReadStream.stdin {
            self.process.standardInput = stdin.processObject
            self.stdin = stdin
        }
    }
    
    private func launch() {
        if forwardInterrupt {
            InterruptPasser.add(self)
        }
        
        self.process.terminationHandler = { [weak self] (process) in
            guard let weakSelf = self else { return }
            if weakSelf.forwardInterrupt {
                InterruptPasser.remove(weakSelf)
            }
            weakSelf.onTermination?(process.terminationStatus)
        }
        
        process.environment = env
        process.launch()
        
        stdout?.closeWrite()
        stderr?.closeWrite()
        stdin?.closeRead()
    }
    
    @discardableResult
    public func runSync() -> Int32 {
        launch()
        return finish()
    }
    
    public func runAsync() {
        launch()
    }
    
    @discardableResult
    public func finish() -> Int32 {
        process.waitUntilExit()
        return process.terminationStatus
    }
    
    public func interrupt() {
        #if os(Linux)
        sendSignal(SIGINT)
        #else
        process.interrupt()
        #endif
    }
    
    public func suspend() -> Bool {
        #if os(Linux)
        return sendSignal(SIGSTOP) == 0
        #else
        return process.suspend()
        #endif
    }
    
    public func resume() -> Bool {
        #if os(Linux)
        return sendSignal(SIGCONT) == 0
        #else
        return process.suspend()
        #endif
    }
    
    public func terminate() {
        #if os(Linux)
        sendSignal(SIGTERM)
        #else
        process.terminate()
        #endif
    }
    
    @discardableResult
    public func sendSignal(_ sig: Int32) -> Int32 {
        return kill(process.processIdentifier, SIGINT)
    }
    
}

// MARK: -

public struct ExecuteError: ProcessError {
    public let exitStatus: Int32
    public let message: String? = nil
}

public struct CaptureError: ProcessError {
    public let exitStatus: Int32
    public let captured: CaptureResult
    
    public var message: String? {
        return captured.stderr
    }
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
