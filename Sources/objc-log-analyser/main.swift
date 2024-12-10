import Foundation

// -- PRE-CONDITIONS --
guard ProcessInfo.processInfo.environment["NSObjCMessageLoggingEnabled"] == "YES" else {
    preconditionFailure("This log analyser requires you enable the environment variable 'NSObjCMessageLoggingEnabled' to record ObjC messages to /tmp")
}

// -- HELPERS --
func collectLog(_ block: () throws -> Void) throws -> [String]{
    // The ObjC log is expected to be written to "/tmp/msgSends-<PID>"
    let processId = ProcessInfo.processInfo.processIdentifier
    let messagesFileUrl = URL(fileURLWithPath: "/tmp/msgSends-\(processId)")
    let fileHandle = try FileHandle(forReadingFrom: messagesFileUrl)
    try fileHandle.seekToEnd()
    
    // Execute the code block to analyse
    try block()
    
    // Collect the logs
    let appendedData = try fileHandle.readToEnd() ?? Data()
    let log = String(data: appendedData, encoding: .utf8) ?? ""
    let logLines = log.components(separatedBy: "\n")
    
    return logLines
}

// -- PREPARE DATA --
// To reduce noise in the captured objc log, prepare as much data before.
let tempPath = URL(fileURLWithPath: NSTemporaryDirectory())
    .appending(path: UUID().uuidString)
    .appendingPathExtension("tmp")
let data = Data()
let manager = FileManager.default

// -- EXECUTE --
let logs = try collectLog {
    // Add statements you want to analyse, i.e.:
    // manager.createFile(atPath: tempPath.absoluteString, contents: data, attributes: nil)
    // try data.write(to: tempPath.absoluteURL)
}

// -- FINALIZE --
print("+-----------------+")
print("| COLLECTED LOGS: |")
print("+-----------------+")
print("")
for log in logs {
    print(log)
}
