import Foundation


public struct Cal {
    var year: Int
    var month: Int
    var day: Int

    func asTimestamp() -> Int {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = NSLocale(localeIdentifier: NSLocale.current.languageCode ?? "en_US_POSIX") as Locale
        let date = formatter.date(from: "\(year)-\(month)-\(day)")
        if date == nil {
            return Cal(year: year, month: month, day: day - 1).asTimestamp()
        }
        return Int(date!.timeIntervalSince1970)
    }

    func asAge() -> Int {
        let timestamp = asTimestamp()
        return timestamp.asAge()
    }
}

public extension Int {
    internal func asCalendar() -> Cal {
        let timestamp = TimeInterval(self)
        let nsDate = NSDate(timeIntervalSince1970: timestamp)
        let date = Date(timeIntervalSinceReferenceDate: nsDate.timeIntervalSinceReferenceDate)

        let cal = NSCalendar.current
        let year = cal.component(.year, from: date)
        let month = cal.component(.month, from: date)
        let day = cal.component(.day, from: date)
        return Cal(year: year, month: month, day: day)
    }

    func asStaledTime() -> String {
        let timestamp: Int = self
        let current = Int(NSDate().timeIntervalSince1970)
        let deltaInSeconds = current - timestamp
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

    func asAge() -> Int {
        let timestamp = self
        let current = Int(Date().timeIntervalSince1970)
        let delta = current - timestamp
        let year = (60 * 60 * 24 * 365)
        let age = delta / year
        return age
    }
}

public extension Optional where Wrapped == Int {

    internal func asCalendar() -> Cal {
        let timestamp = self ?? 0
        return timestamp.asCalendar()
    }

    func asStaledTime() -> String {
        guard (self != nil) else {
            return "과거"
        }
        return self!.asStaledTime()
    }

    func asAge() -> Int? {
        guard (self != nil) else {
            return nil
        }
        let timestamp = self!
        let current = Int(Date().timeIntervalSince1970)
        let delta = current - timestamp
        let year = (60 * 60 * 24 * 365)
        let age = delta / year
        return age
    }
}