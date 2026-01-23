import Foundation
import UIKit

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

        // ✅ Check if date is today
        guard calendar.isDateInToday(videoDateTime) else {
            return false
        }

        let currentTime = Date()
        let minutesDifference = currentTime.timeIntervalSince(videoDateTime) / 60

        return minutesDifference >= Double(minDifference)
    }

    // MARK: - Date Parsing (with & without seconds)
    private func parseDate(_ dateString: String) -> Date? {

        let formats = [
            "dd-MM-yyyy hh:mm:ss a", // with seconds
            "dd-MM-yyyy hh:mm a"     // without seconds
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
