import Foundation

extension DateFormatter {

    private static let longInseatOrderDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, dd/MM/yy, HH:mm"
        return formatter
    }()

    private static let shortInseatOrderDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yy, HH:mm"
        return formatter
    }()

    static func orderDateString(from date: Date) -> String {
        if shortInseatOrderDateFormatter.calendar.isDateInToday(date) {
            return "Today, " + shortInseatOrderDateFormatter.string(from: date)
        }
        if shortInseatOrderDateFormatter.calendar.isDateInYesterday(date) {
            return "Yesterday, " + shortInseatOrderDateFormatter.string(from: date)
        }
        return longInseatOrderDateFormatter.string(from: date)
    }
}

