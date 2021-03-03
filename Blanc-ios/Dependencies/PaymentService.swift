import Foundation
import Moya
import RxSwift
import Firebase
import RxFirebase


class PaymentService {

    let provider = MoyaProvider<PaymentProvider>(plugins: [
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

    func purchase(currentUser: User, uid: String, userId: String, token: String) -> Single<PaymentDTO> {
        currentUser.rx.getIDTokenResult()
                .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
                .observeOn(SerialDispatchQueueScheduler(qos: .default))
                .flatMap { [unowned self] result in
                    provider.rx.request(.purchase(
                                    idToken: result.token,
                                    uid: uid,
                                    userId: userId,
                                    token: token)
                            )
                            .debug()
                            .filterSuccessfulStatusAndRedirectCodes()
                            .map(PaymentDTO.self, using: decoder)
                            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
                }
                .asSingle()
    }
}