import Foundation

extension DateFormatter {

    private final class UTCDateFormatter: DateFormatter, @unchecked Sendable {
        init(locale: Locale = Locale(identifier: "en_US_POSIX")) {
            super.init()
            calendar = Calendar(identifier: .gregorian)
            timeZone = TimeZone(identifier: "UTC")!
            self.locale = locale
        }

        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }

    static let inseatOrderDateFormatter: DateFormatter = {
        let formatter = UTCDateFormatter()
        formatter.dateFormat = "dd/MM/yy, HH:mm"
        return formatter
    }()
}
