import Inseat

final class InseatLoggingDestination: LoggingDestination {

    func log(_ level: Inseat.LogLevel, _ message: String) {
        let logLevel: LogLevel
        switch level {
        case .debug:
            logLevel = .debug
        case .warning:
            logLevel = .warning
        case .info:
            logLevel = .info
        case .error:
            logLevel = .error
        case .critical:
            logLevel = .critical
        @unknown default:
            logLevel = .debug
        }
        Logger.log(message, level: logLevel)
    }
}
