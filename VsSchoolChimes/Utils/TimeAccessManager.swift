import Foundation
final class TimeAccessManager {

    static let shared = TimeAccessManager()
    private init() {}

    func canAllowFlow(
        dateAndTime: String,
        minDifference: Int = 30
    ) -> Bool {

        guard let videoDateTime = parseDate(dateAndTime) else {
            return false
        }

        let calendar = Calendar.current
        let currentTime = Date()

        // 🔹 If NOT today → allow directly
        if !calendar.isDateInToday(videoDateTime) {
            return true
        }

        // 🔹 If today → check time difference
        let minutesDifference = currentTime.timeIntervalSince(videoDateTime) / 60

        return minutesDifference >= Double(minDifference)
    }

    // MARK: - Handles with & without seconds
    private func parseDate(_ dateString: String) -> Date? {

        let formats = [
            "dd-MM-yyyy hh:mm:ss a",
            "dd-MM-yyyy hh:mm a"
        ]

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone.current

        for format in formats {
            formatter.dateFormat = format
            if let date = formatter.date(from: dateString) {
                return date
            }
        }

        return nil
    }
}
