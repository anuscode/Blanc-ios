import Moya

enum AlarmProvider {
    case listAlarms(uid: String?)
    case updateAllAlarmsAsRead(uid: String?)
}


extension AlarmProvider: TargetType {

    var baseURL: URL {
        URL(string: Constant.url)!
    }

    var path: String {
        switch self {
        case .listAlarms(uid: _):
            return "alarms"
        case .updateAllAlarmsAsRead(uid: _):
            return "alarms"
        }
    }

    var method: Moya.Method {
        switch self {
        case .listAlarms(uid: _):
            return .get
        case .updateAllAlarmsAsRead(uid: _):
            return .put
        }
    }

    var sampleData: Data {
        Data()
    }

    var task: Task {
        switch self {
        case .listAlarms(uid: _):
            return .requestPlain
        case .updateAllAlarmsAsRead(uid: _):
            return .requestPlain
        }
    }

    var headers: [String: String]? {
        var headers = ["Content-Type": "application/json"]
        switch self {
        case .listAlarms(uid: let uid):
            headers["uid"] = uid
            return headers
        case .updateAllAlarmsAsRead(uid: let uid):
            headers["uid"] = uid
            return headers
        }
    }
}
