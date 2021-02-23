import Foundation

public extension Optional where Wrapped == Int {
    func convertToStaledTime() -> String {
        let timestamp: Int? = self

        guard (timestamp != nil) else {
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