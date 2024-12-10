import Darwin
import Foundation

/**
 * Collects the ObjC log from the file `/tmp/msgSends-<PID>`
 *
 * Note: This function is designed to reduce the amount of spawned ObjC messages by using C file operations.
 *
 * - Parameter block: The code block to execute to analyze the log
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
    
    // Execute the code block to analyze
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
