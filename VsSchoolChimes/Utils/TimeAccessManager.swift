import UIKit

final class TimeAccessManager {

    static let shared = TimeAccessManager()
    private init() {}

    // MARK: - Main Validation Function
    func canAllowFlow(
        dateAndTime: String,
        minDifference: Int = 30
    ) -> Bool {

        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy hh:mm a"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone.current

        guard let videoDateTime = formatter.date(from: dateAndTime) else {
            return false
        }

        let calendar = Calendar.current

        // Check if today
        guard calendar.isDateInToday(videoDateTime) else {
            return false
        }

        let currentTime = Date()
        let minutesDifference = currentTime.timeIntervalSince(videoDateTime) / 60

        return minutesDifference >= Double(minDifference)
    }
}
