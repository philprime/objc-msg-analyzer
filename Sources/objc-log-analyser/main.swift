import Foundation

// -- PRE-CONDITIONS --

guard ProcessInfo.processInfo.environment["NSObjCMessageLoggingEnabled"] == "YES" else {
    preconditionFailure("This log analyser requires you enable the environment variable 'NSObjCMessageLoggingEnabled' to record ObjC messages to /tmp")
}

// -- HELPERS --

/**
 * Collects the ObjC log from the file `/tmp/msgSends-<PID>`
 *
 * Note: This function is designed to reduce the amount of spawned ObjC messages by using C file operations.    
 *
 * - Parameter block: The code block to execute to analyse the log
 * - Returns: The log lines
 * - Throws: If the Objective-C messages file cannot be opened or read
 * - Throws: Any error thrown in the given `block`
 */
func collectLogs(_ block: () throws -> Void) throws -> [String] {
    // The ObjC log is expected to be written to "/tmp/msgSends-<PID>"
    let processId = getpid()
    let messagesFilePath = "/tmp/msgSends-\(processId)"
    
    // Open file using C file operations to reduce the amount of spawned ObjC messages
    guard let file = fopen(messagesFilePath, "r") else {
        throw NSError(domain: NSPOSIXErrorDomain, code: Int(errno))
    }
    defer { fclose(file) }
    
    // Seek to end to drop any previously generated log
    fseek(file, 0, SEEK_END)
    let initialPosition = ftell(file)
    
    // Execute the code block to analyse
    try block()
    
    // Get file size after execution
    fseek(file, 0, SEEK_END)
    let finalPosition = ftell(file)
    let dataSize = finalPosition - initialPosition
    
    // Return to position where we started
    fseek(file, initialPosition, SEEK_SET)
    
    // Read the newly appended data
    var buffer = [UInt8](repeating: 0, count: dataSize)
    let bytesRead = fread(&buffer, 1, dataSize, file)
    
    // Validate that the full data has been read into the buffer
    guard bytesRead == dataSize else {
        throw NSError(domain: NSPOSIXErrorDomain, code: Int(errno))
    }
    
    // Convert to string and split into lines
    let data = Data(buffer)
    guard let log = String(data: data, encoding: .utf8) else {
        return []
    }
    return log.components(separatedBy: "\n")
}

// -- PREPARE DATA --
// To reduce noise in the captured objc log, prepare as much data before executing the code block.
let tempPath = URL(fileURLWithPath: NSTemporaryDirectory())
    .appending(path: UUID().uuidString)
    .appendingPathExtension("tmp")
let data = Data()
let manager = FileManager.default

// -- EXECUTE --
let logs = try collectLogs {
    manager.createFile(atPath: tempPath.absoluteString, contents: data, attributes: nil)
}

// -- FINALIZE --
print("+-----------------+")
print("| COLLECTED LOGS: |")
print("+-----------------+")
print("")
for log in logs {
    print(log)
}
