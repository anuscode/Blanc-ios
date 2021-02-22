import Foundation

struct Cal {
    var year: Int
    var month: Int
    var day: Int
}

class Time {
    static func convertTimestampToCalendar(timestamp: Int) -> Cal {
        let timestamp = TimeInterval(timestamp)
        let nsDate = NSDate(timeIntervalSince1970: timestamp)
        let date = Date(timeIntervalSinceReferenceDate: nsDate.timeIntervalSinceReferenceDate)

        let cal = NSCalendar.current
        let year = cal.component(.year, from: date)
        let month = cal.component(.month, from: date)
        let day = cal.component(.day, from: date)
        return Cal(year: year, month: month, day: day)
    }

    static func convertCalendarToTimestamp(year: Int, month: Int, day: Int) -> Int {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = NSLocale(localeIdentifier: NSLocale.current.languageCode ?? "en_US_POSIX") as Locale
        var date = formatter.date(from: "\(year)-\(month)-\(day)")
        if date == nil {
            return convertCalendarToTimestamp(year: year, month: month, day: day - 1)
        }
        return Int(date!.timeIntervalSince1970)
    }

    static func calculateAge(year: Int, month: Int, day: Int) -> Int {
        let timestamp = convertCalendarToTimestamp(year: year, month: month, day: day)
        let currentTimestamp = Int(Date().timeIntervalSince1970)
        let delta = currentTimestamp - timestamp
        let year = (60 * 60 * 24 * 365)
        let age = delta / year
        return age
    }

    static func calculateAge(birthedAt: Int?) -> Int? {
        guard birthedAt != nil else {
            return nil
        }
        let timestamp = birthedAt
        let currentTimestamp = Int(Date().timeIntervalSince1970)
        let delta = currentTimestamp - timestamp!
        let year = (60 * 60 * 24 * 365)
        let age = delta / year
        return age
    }

    static func calculateStaledTime(timestamp: Int?) -> String {
        if (timestamp == nil) {
            return "과거"
        }
        let current = Int(NSDate().timeIntervalSince1970)
        let deltaInSeconds = current - timestamp!
        let deltaInMinutes = deltaInSeconds / 60
        if (deltaInMinutes < 60) {
            return "\(deltaInMinutes) 분 전"
        }
        let deltaInHours = deltaInMinutes / 60
        if (deltaInHours < 24) {
            return "\(deltaInHours) 시간 전"
        }
        let deltaInDays = deltaInHours / 24
        return "\(deltaInDays) 일 전"
    }
}
