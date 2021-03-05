import Foundation
import Moya
import RxSwift


class AlarmService {

    let provider = MoyaProvider<AlarmProvider>(plugins: [
        //NetworkLoggerPlugin(configuration: NetworkLoggerPlugin.Configuration(logOptions: .verbose))
    ])

    private enum CodingKeys: String, CodingKey {
        case number
    }

    var decoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }

    // GET
    func listAlarms(uid: String?) -> Single<[PushDTO]> {
        provider.rx
            .request(.listAlarms(uid: uid))
            .debug()
            .filterSuccessfulStatusAndRedirectCodes()
            .map([PushDTO].self, using: decoder)
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
    }

    func updateAllAlarmsAsRead(uid: String?) -> Single<Void> {
        provider.rx
            .request(.updateAllAlarmsAsRead(uid: uid))
            .debug()
            .filterSuccessfulStatusAndRedirectCodes()
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
            .map({ _ in Void() })
    }
}