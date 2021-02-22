import Foundation

struct Preferences {

    private let PREFERENCE_TOKEN_STORAGE_KEY = "FCM_DEVICE_TOKEN"

    private let preferences = UserDefaults.standard

    private func getString(_ key: String) -> String? {
        preferences.string(forKey: key)
    }

    private func setString(key: String, value: String) {
        preferences.set(value, forKey: key)
    }

    private func getBoolean(_ key: String) -> Bool? {
        preferences.bool(forKey: key)
    }

    private func setBoolean(key: String, value: Bool) {
        preferences.set(value, forKey: key)
    }

    func setDeviceToken(token: String?) {
        if (token == nil) {
            return
        }
        setString(key: PREFERENCE_TOKEN_STORAGE_KEY, value: token!)
    }

    func getDeviceToken() -> String? {
        getString(PREFERENCE_TOKEN_STORAGE_KEY)
    }

}
