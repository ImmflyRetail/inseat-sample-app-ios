enum LogLevel: String {
    case debug
    case warning
    case info
    case error
    case critical
}

enum Logger {

    static func log(_ message: String, level: LogLevel) {
        print("[\(level.rawValue.uppercased())] \(message)")
    }
}
