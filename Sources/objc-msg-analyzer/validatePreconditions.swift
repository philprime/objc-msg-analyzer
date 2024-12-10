import Foundation

/**
 * Validates the preconditions for the tool.
 *
 * This function will exit the process if the preconditions are not met.
 */
func validatePreconditions() {
    guard ProcessInfo.processInfo.environment["NSObjCMessageLoggingEnabled"] == "YES" else {
        preconditionFailure("This log analyzer requires you enable the environment variable 'NSObjCMessageLoggingEnabled' to 'YES' (uppercase) to record ObjC messages to /tmp/msgSends-<PID>")
    }
}
