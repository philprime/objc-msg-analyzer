import Foundation

// -- PRE-CONDITIONS --
validatePreconditions()

// -- PREPARE DATA --
// To reduce noise in the captured objc log, prepare as much data before executing the code block.
let tempDir = NSTemporaryDirectory()
let tempPath = URL(fileURLWithPath: tempDir)
    .appending(path: UUID().uuidString)
    .appendingPathExtension("tmp")
let data = Data()
let manager = FileManager.default

// -- EXECUTE --
let logs = try collectLogs {
    // manager.createFile(atPath: tempPath.absoluteString, contents: data, attributes: nil)
    let _ = NSString("Hello World")
}

// -- FINALIZE --
print("+-----------------+")
print("| COLLECTED LOGS: |")
print("+-----------------+")
print("")
if logs.isEmpty {
    print("No logs collected")
} else {
    for log in logs {
        print(log)
    }
}
