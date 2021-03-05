import Foundation
import Moya
import RxSwift
import Firebase
import RxFirebase


class RequestService {

    let provider = MoyaProvider<RequestProvider>(plugins: [
        // NetworkLoggerPlugin(configuration: NetworkLoggerPlugin.Configuration(logOptions: .verbose))
    ])

    var decoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }

    // GET
    func listRequests(uid: String?) -> Single<[RequestDTO]> {
        provider.rx
            .request(.listRequests(uid: uid))
            .debug()
            .filterSuccessfulStatusAndRedirectCodes()
            .map([RequestDTO].self, using: decoder)
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
    }

    func getRequest(uid: String?, requestId: String?) -> Single<RequestDTO> {
        provider.rx
            .request(.getRequest(uid: uid, requestId: requestId))
            .debug()
            .filterSuccessfulStatusAndRedirectCodes()
            .map(RequestDTO.self, using: decoder)
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
    }

    func createRequest(currentUser: User, uid: String?, userId: String?, requestType: RequestType) -> Single<RequestDTO> {
        currentUser.rx
            .getIDTokenResult()
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
            .observeOn(SerialDispatchQueueScheduler(qos: .default))
            .flatMap { [unowned self] result in
                provider.rx.request(.createRequest(
                        idToken: result.token,
                        uid: uid,
                        userId: userId,
                        requestType: requestType))
                    .debug()
                    .filterSuccessfulStatusAndRedirectCodes()
                    .map(RequestDTO.self, using: decoder)
            }
            .asSingle()
    }

    func updateRequest(uid: String?, requestId: String?, response: Response) -> Single<Void> {
        provider.rx
            .request(.updateRequest(uid: uid, requestId: requestId, response: response))
            .debug()
            .filterSuccessfulStatusAndRedirectCodes()
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
            .map({ _ in Void() })
    }
}
