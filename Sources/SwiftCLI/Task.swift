//
//  Task.swift
//  SwiftCLI
//
//  Created by Jake Heiser on 4/1/18.
//

import Foundation

// MARK: -

/// Run an executable synchronously; uses this process's stdout, stderr, and stdin
///
/// - Parameters:
///   - executable: the executable to run
///   - directory: the directory to run in
///   - args: arguments to pass to the executable
/// - Throws: RunError if command fails
public func run(_ executable: String, directory: String? = nil, _ args: String...) throws {
    try run(executable, directory: directory, args)
}

/// Run an executable synchronously; uses this process's stdout, stderr, and stdin
///
/// - Parameters:
///   - executable: the executable to run
///   - directory: the directory to run in
///   - args: arguments to pass to the executable
/// - Throws: RunError if command fails
public func run(_ executable: String, directory: String? = nil, _ args: [String]) throws {
    let task = Task(executable: executable, args: args, currentDirectory: directory)
    let code = task.runSync()
    guard code == 0 else {
        throw RunError(exitStatus: code)
    }
}

/// Run an executable synchronously and capture its output
///
/// - Parameters:
///   - executable: the executable to run
///   - directory: the directory to run in
///   - args: arguments to pass to the executable
/// - Returns: the captured data
/// - Throws: CaptureError if command fails
public func capture(_ executable: String, directory: String? = nil, _ args: String...) throws -> CaptureResult {
    return try capture(executable, directory: directory, args)
}

/// Run an executable synchronously and capture its output
///
/// - Parameters:
///   - executable: the executable to run
///   - directory: the directory to run in
///   - args: arguments to pass to the executable
/// - Returns: the captured data
/// - Throws: CaptureError if command fails
public func capture(_ executable: String, directory: String? = nil, _ args: [String]) throws -> CaptureResult {
    let out = PipeStream()
    let err = PipeStream()
    
    let task = Task(executable: executable, args: args, currentDirectory: directory, stdout: out, stderr: err)
    let exitCode = task.runSync()
    
    let captured = CaptureResult(rawStdout: out.readAll(), rawStderr: err.readAll())
    guard exitCode == 0 else {
        throw CaptureError(exitStatus: exitCode, captured: captured)
    }
    
    return captured
}

/// Run a bash statement synchronously; uses this process's stdout, stderr, and stdin
///
/// - Parameters:
///   - bash: the bash statement to run
///   - directory: the directory to run in
/// - Throws: RunError if command fails
/// - Warning: Do not use this with unsanitized user input, can be dangerous
public func run(bash: String, directory: String? = nil) throws {
    try run("/bin/bash", directory: directory, "-c", bash)
}

/// Run a bash statement synchronously and capture its output
///
/// - Parameters:
///   - bash: the bash statement to run
///   - directory: the directory to run in
/// - Returns: the captured data
/// - Throws: CaptureError if command fails
/// - Warning: Do not use this with unsanitized user input, can be dangerous
public func capture(bash: String, directory: String? = nil) throws -> CaptureResult {
    return try capture("/bin/bash", directory: directory, "-c", bash)
}

// MARK: -

public class Task {
    
    /// Finds the path to an executable
    ///
    /// - Parameter named: the name of the executable to find
    /// - Returns: the full path to the executable if found, or nil
    public static func findExecutable(named: String) -> String? {
        if named.hasPrefix("/") || named.hasPrefix(".") {
            return named
        }
        return try? capture(bash: "which \(named)").stdout
    }
    
    /// Run the given executable, replacing the current process with it
    ///
    /// - Parameters:
    ///   - executable: executable to run
    ///   - args: arguments to the executable
    /// - Returns: Never
    /// - Throws: CLI.Error if the executable could not be found
    public static func execvp(executable: String, args: [String] = []) throws -> Never {
        let argv = ([executable] + args).map({ $0.withCString(strdup) })
        defer { argv.forEach { free($0)} }
        
        Foundation.execvp(executable, argv + [nil])
        
        throw CLI.Error(message: "\(executable) not found")
    }
    
    private let process: Process
    
    /// Block to execute when command terminates; default nil
    public var onTermination: ((Int32) -> ())? = nil
    
    /// Environment in which to execute the task; defaults to same as this process
    public var env: [String: String] = ProcessInfo.processInfo.environment
    
    /// Whether interrupt signals which this process receives should be forwarded to this task; defaults to true
    /// - Warning: when true, SwiftCLI takes over the signal handler for SIGINT which removes any handler that is already in place
    public var forwardInterrupt = true
    
    /// The id of the running task
    public var pid: Int32 { return process.processIdentifier }
    
    /// Whether task is currently running
    public var isRunning: Bool { return process.isRunning }
    
    /// Create a new task
    ///
    /// - Parameters:
    ///   - executable: the executable to run
    ///   - args: the arguments with which to run the executable; defaults to no arguments
    ///   - currentDirectory: the directory to run the executable in; defaults to the current process's directory
    ///   - stdout: the stream which the task should use as it's standard output; defaults to the current process's stdout
    ///   - stderr: the stream which the task should use as it's standard error; defaults to the current process's stderr
    ///   - stdin: the stream which the task should use as it's standard input; defaults to the current process's stdin
    public init(executable: String, args: [String] = [], currentDirectory: String? = nil, stdout: WritableStream = WriteStream.stdout, stderr: WritableStream = WriteStream.stderr, stdin: ReadableStream = ReadStream.stdin) {
        self.process = Process()
        if executable.hasPrefix("/") || executable.hasPrefix(".") {
            self.process.launchPath = executable
            self.process.arguments = args
        } else {
            self.process.launchPath = "/usr/bin/env"
            self.process.arguments = [executable] + args
        }
        if let currentDirectory = currentDirectory {
            self.process.currentDirectoryPath = currentDirectory
        }
        
        if (stdout as? WriteStream) !== WriteStream.stdout {
            self.process.standardOutput = stdout.processObject
        }
        if (stderr as? WriteStream) !== WriteStream.stderr {
            self.process.standardError = stderr.processObject
        }
        if (stdin as? ReadStream) !== ReadStream.stdin {
            self.process.standardInput = stdin.processObject
        }
    }
    /// Run the task and wait for it to finish
    ///
    /// - Returns: the exit code of the completed task
    @discardableResult
    public func runSync() -> Int32 {
        launch()
        return finish()
    }
    
    /// Run the task but do not wait for it to complete
    public func runAsync() {
        launch()
    }
    
    /// Wait for the task to finish; must have already called runAsync
    ///
    /// - Returns: the exit code of the completed task
    @discardableResult
    public func finish() -> Int32 {
        process.waitUntilExit()
        return process.terminationStatus
    }
    
    /// Send the task an interrupt signal
    public func interrupt() {
        #if os(Linux)
        sendSignal(SIGINT)
        #else
        process.interrupt()
        #endif
    }
    
    /// Attempt to suspend the task by sending a stop signal
    ///
    /// - Returns: whether it was successful
    public func suspend() -> Bool {
        #if os(Linux)
        return sendSignal(SIGSTOP) == 0
        #else
        return process.suspend()
        #endif
    }
    
    /// Attempt to resume the task by sending a continue signal
    ///
    /// - Returns: whether it was successful
    public func resume() -> Bool {
        #if os(Linux)
        return sendSignal(SIGCONT) == 0
        #else
        return process.resume()
        #endif
    }
    
    /// Terminates the task by sending a terminate signal
    public func terminate() {
        #if os(Linux)
        sendSignal(SIGTERM)
        #else
        process.terminate()
        #endif
    }
    
    /// Send a signal to the task
    ///
    /// - Parameter sig: the signal to send
    /// - Returns: result of signal send; 0 means success
    @discardableResult
    public func sendSignal(_ sig: Int32) -> Int32 {
        return kill(pid, sig)
    }
    
    // Helpers
    
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
    }
    
}

// MARK: -

/// The error thrown by run(...) and run(bash:)
public struct RunError: ProcessError {
    
    /// The status which the task exited with
    public let exitStatus: Int32
    
    public let message: String? = nil
}

/// The error thrown by capture(...) and capture(bash:)
public struct CaptureError: ProcessError {
    
    /// The status which the task exited with
    public let exitStatus: Int32
    
    /// Data which was captured prior to the process failing
    public let captured: CaptureResult
    
    public var message: String? {
        return captured.stderr
    }
}

public struct CaptureResult {
    /// The full stdout contents; use `stdout` for trimmed contents
    public let rawStdout: String
    
    /// The full stderr contents; use `stderr` for trimmed contents
    public let rawStderr: String
    
    /// The stdout contents, trimmed of whitespace
    public var stdout: String {
        return rawStdout.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    /// The stderr contents, trimmed of whitespace
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
