import Foundation
import Moya
import RxSwift
import Firebase
import RxFirebase


class VerificationService {

    let provider = MoyaProvider<VerificationProvider>(plugins: [
        // NetworkLoggerPlugin(configuration: NetworkLoggerPlugin.Configuration(logOptions: .verbose))
    ])

    var decoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }

    func issueSmsCode(currentUser: User, uid: String?, phone: String?) -> Single<VerificationDTO> {
        currentUser.rx.getIDTokenResult()
                .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
                .flatMap { [unowned self] result in
                    provider.rx.request(.issueSmsCode(idToken: result.token, uid: uid, phone: phone))
                            .debug()
                            .filterSuccessfulStatusAndRedirectCodes()
                            .map(VerificationDTO.self, using: decoder)
                }
                .asSingle()
    }

    func verifySmsCode(currentUser: User,
                       uid: String?,
                       phone: String?,
                       smsCode: String?,
                       expiredAt: Int?) -> Single<VerificationDTO> {
        currentUser.rx.getIDTokenResult()
                .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
                .flatMap { [unowned self] result -> Single<VerificationDTO> in
                    provider.rx.request(.verifySmsCode(
                                    idToken: result.token,
                                    uid: uid,
                                    phone: phone,
                                    smsCode: smsCode,
                                    expiredAt: expiredAt))
                            .debug()
                            .filterSuccessfulStatusAndRedirectCodes()
                            .map(VerificationDTO.self, using: decoder)
                }
                .asSingle()
    }
}
