# Objective-C Message Log Analyzer

A Swift tool designed to capture and analyze Objective-C message sends during code execution. 

## Motivation

When calling methods on Objective-C objects, i.e. `[NSString alloc]`, the Objective-C runtime uses the `objc_msgSend` function to lookup the method implementation and call it.
Using "swizzling" the implementation called by `objc_msgSend` can be replaced with a custom implementation.

Swift itself does not use the `objc_msgSend` function, so it does not support swizzling.
But many Swift frameworks use Objective-C runtime features, e.g. `@objc` methods, `NSObject` methods, etc.

This tool leverages the Objective-C runtime's message logging capability to help debug and understand Objective-C message patterns in your code.

## Prerequisites

Before using this tool, you need to enable Objective-C message logging by setting the following environment variable `NSObjCMessageLoggingEnabled` to `YES`. This will create a file at `/tmp/msgSends-<PID>` where the messages will be logged (see [Apple Technote TN2124](https://developer.apple.com/library/archive/technotes/tn2124/_index.html#//apple_ref/doc/uid/DTS10003391-CH1-SECOBJECTIVEC) for more details).

Objective-C message logging is only available in debug builds for macOS.
It appears to not be available on iOS or the simulator.

## Usage

1. Clone this repository
2. Open `Package.swift` with Xcode
3. Edit the `main.swift` file to add your code block to execute, i.e.:  

```swift
let logs = try collectLogs {
    let _ = NSString("Hello World")
}
```

4. Make sure the environment variable for the Run scheme is set:

```bash
NSObjCMessageLoggingEnabled=YES
```

5. Run the analyzer

## How It Works

The analyzer performs the following steps:

1. Opens the message log file at `/tmp/msgSends-<PID>`
3. Executes your code block
4. Captures all Objective-C messages sent during execution
5. Prints the collected logs

### Implementation Details

The tool is designed to minimize its own impact on the logged messages by:
- Using C-level file operations instead of higher-level APIs
- Preparing data structures before the analysis
- Capturing only new messages during the execution block

### Example

This is an example code block that will be executed (see `main.swift`):

```swift
let logs = try collectLogs {
    let _ = NSString("Hello World")
}
```

The output will something look like this:

```
+-----------------+
| COLLECTED LOGS: |
+-----------------+

+ NSString NSString allocWithZone:
- NSPlaceholderString NSPlaceholderString initWithBytesNoCopy:length:encoding:freeWhenDone:
+ NSString NSString allocWithZone:
- NSPlaceholderString NSPlaceholderString initWithString:
- __NSCFString __NSCFString release
- __NSCFString __NSCFString release
```

Based on this output, you can see that the `NSString` class is allocated twice, and the `NSPlaceholderString` class is allocated once.
In addition string literals are allocated as `__NSCFString` instances and released twice.