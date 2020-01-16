//
//  Task.swift
//  SwiftCLI
//
//  Created by Jake Heiser on 4/1/18.
//

import Foundation

// MARK: -

public class Task {
    
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
    
    /// The standard out stream for the task
    public let stdout: WritableStream
    
    /// The standard error stream for the task
    public let stderr: WritableStream
    
    /// The standard input stream for the task
    public let stdin: ReadableStream
    
    /// Create a new task
    ///
    /// - Parameters:
    ///   - executable: the executable to run
    ///   - arguments: the arguments with which to run the executable; defaults to no arguments
    ///   - directory: the directory to run the executable in; defaults to the current process's directory
    ///   - stdout: the stream which the task should use as it's standard output; defaults to the current process's stdout
    ///   - stderr: the stream which the task should use as it's standard error; defaults to the current process's stderr
    ///   - stdin: the stream which the task should use as it's standard input; defaults to the current process's stdin
    public init(executable: String, arguments: [String] = [], directory: String? = nil, stdout: WritableStream = Term.stdout, stderr: WritableStream = Term.stderr, stdin: ReadableStream = ReadStream.stdin) {
        self.process = Process()
        if executable.hasPrefix("/") || executable.hasPrefix(".") {
            self.process.launchPath = executable
            self.process.arguments = arguments
        } else {
            self.process.launchPath = "/usr/bin/env"
            self.process.arguments = [executable] + arguments
        }
        if let directory = directory {
            self.process.currentDirectoryPath = directory
        }
        
        if stdout !== WriteStream.stdout {
            self.process.standardOutput = stdout.processObject
        }
        if stderr !== WriteStream.stderr {
            self.process.standardError = stderr.processObject
        }
        if stdin !== ReadStream.stdin {
            self.process.standardInput = stdin.processObject
        }
        
        self.stdout = stdout
        self.stderr = stderr
        self.stdin = stdin
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
    /// - Parameter waitForStreams: whether stdout and stderr should be waited on if they are ProcessingStreams (LineStream or CaptureStream);
    /// default true
    /// - Returns: the exit code of the completed task
    @discardableResult
    public func finish(waitForStreams: Bool = true) -> Int32 {
        process.waitUntilExit()
        if waitForStreams {
            if let stream = stdout as? ProcessingStream {
                stream.waitToFinishProcessing()
            }
            if let stream = stderr as? ProcessingStream {
                stream.waitToFinishProcessing()
            }
        }
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

extension Task {
    
    /// Run an executable synchronously; uses this process's stdout, stderr, and stdin
    ///
    /// - Parameters:
    ///   - executable: the executable to run
    ///   - arguments: arguments to pass to the executable
    /// - Throws: RunError if command fails
    public static func run(_ executable: String, _ arguments: String...) throws {
        try run(executable, arguments: arguments)
    }
    
    /// Run an executable synchronously; uses this process's stdout, stderr, and stdin
    ///
    /// - Parameters:
    ///   - executable: the executable to run
    ///   - arguments: arguments to pass to the executable
    ///   - directory: the directory to run in; default current directory
    /// - Throws: RunError if command fails
    public static func run(_ executable: String, arguments: [String], directory: String? = nil) throws {
        let task = Task(executable: executable, arguments: arguments, directory: directory)
        let code = task.runSync()
        guard code == 0 else {
            throw RunError(exitStatus: code)
        }
    }
    
    /// Run an executable synchronously and capture its output
    ///
    /// - Parameters:
    ///   - executable: the executable to run
    ///   - arguments: arguments to pass to the executable
    /// - Returns: the captured data
    /// - Throws: CaptureError if command fails
    public static func capture(_ executable: String, _ arguments: String...) throws -> CaptureResult {
        return try capture(executable, arguments: arguments)
    }
    
    
    /// Run an executable synchronously and capture its output
    ///
    /// - Parameters:
    ///   - executable: the executable to run
    ///   - arguments: arguments to pass to the executable
    ///   - directory: the directory to run in; default current directory
    ///   - forwardInterrupt: Whether interrupt signals which this process receives should be forwarded to this task; defaults to true
    ///   - env: Environment in which to execute the task; defaults to same as this process
    /// - Returns: the captured data
    /// - Throws: CaptureError if command fails
    public static func capture(_ executable: String, arguments: [String], directory: String? = nil, forwardInterrupt: Bool = true, env: [String: String] = ProcessInfo.processInfo.environment) throws -> CaptureResult {
        let out = CaptureStream()
        let err = CaptureStream()
        
        let task = Task(executable: executable, arguments: arguments, directory: directory, stdout: out, stderr: err)
        task.env = env
        task.forwardInterrupt = forwardInterrupt
        let exitCode = task.runSync()
        
        let captured = CaptureResult(stdoutData: out.readAllData(), stderrData: err.readAllData())
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
    public static func run(bash: String, directory: String? = nil) throws {
        try run("/bin/bash", arguments: ["-c", bash], directory: directory)
    }
    
    /// Run a bash statement synchronously and capture its output
    ///
    /// - Parameters:
    ///   - bash: the bash statement to run
    ///   - directory: the directory to run in
    /// - Returns: the captured data
    /// - Throws: CaptureError if command fails
    /// - Warning: Do not use this with unsanitized user input, can be dangerous
    public static func capture(bash: String, directory: String? = nil) throws -> CaptureResult {
        return try capture("/bin/bash", arguments: ["-c", bash], directory: directory)
    }
    
    /// Run the given executable, replacing the current process with it
    ///
    /// - Parameters:
    ///   - executable: executable to run
    ///   - directory: the directory to run in; default current directory
    ///   - arguments: arguments to the executable
    ///   - env: the environment in which to execute the task; default same env as current process
    /// - Returns: Never
    /// - Throws: CLI.Error if the executable could not be found
    public static func execvp(_ executable: String, arguments: [String], directory: String? = nil, env: [String: String]? = nil) throws -> Never {
        let exec: String
        var swiftArgs: [String] = []
        if executable.hasPrefix("/") || executable.hasPrefix(".") {
            exec = executable
            swiftArgs = arguments
        } else {
            exec = "/usr/bin/env"
            swiftArgs = [executable] + arguments
        }
        
        let argv = ([exec] + swiftArgs).map({ $0.withCString(strdup) })
        defer { argv.forEach { free($0)} }
        
        var priorDir: String? = nil
        if let directory = directory {
            priorDir = FileManager.default.currentDirectoryPath
            FileManager.default.changeCurrentDirectoryPath(directory)
        }
        
        if let env = env {
            let envp = UnsafeMutablePointer<UnsafeMutablePointer<Int8>?>.allocate(capacity: env.count + 1)
            envp.initialize(from: env.map { strdup("\($0)=\($1)") }, count: env.count)
            envp[env.count] = nil
            defer {
                for pair in envp ..< envp + env.count {
                    free(UnsafeMutableRawPointer(pair.pointee))
                }
                #if swift(>=4.1)
                envp.deallocate()
                #else
                envp.deallocate(capacity: env.count + 1)
                #endif
            }
            
            Foundation.execve(exec, argv + [nil], envp)
        } else {
            Foundation.execvp(exec, argv + [nil])
        }
        
        if let priorDir = priorDir {
            FileManager.default.changeCurrentDirectoryPath(priorDir)
        }
        
        throw CLI.Error(message: "\(executable) not found")
    }
    
}

extension Task: CustomStringConvertible {
    public var description: String {
        var str = "Task(" + process.launchPath! + " " + process.arguments!.joined(separator: " ")
        if process.currentDirectoryPath != FileManager.default.currentDirectoryPath {
            str += " , directory: " + process.currentDirectoryPath
        }
        str += ")"
        return str
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
    
    /// The full stdout data
    public let stdoutData: Data
    
    /// The full stderr data
    public let stderrData: Data
    
    /// The stdout contents, trimmed of whitespace
    public var stdout: String {
        return String(data: stdoutData, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
    }
    
    /// The stderr contents, trimmed of whitespace
    public var stderr: String {
        return String(data: stderrData, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
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
