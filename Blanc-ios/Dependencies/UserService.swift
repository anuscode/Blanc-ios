import Foundation
import Moya
import RxSwift
import Firebase
import RxFirebase

class UserService {

    let provider = MoyaProvider<UserProvider>(plugins: [
        // NetworkLoggerPlugin(configuration: NetworkLoggerPlugin.Configuration(logOptions: .verbose))
    ])

    var decoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }

    func getSession(currentUser: User, uid: String?) -> Single<UserDTO> {
        currentUser.rx.getIDTokenResult()
                .debug()
                .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
                .observeOn(SerialDispatchQueueScheduler(qos: .default))
                .flatMap { [unowned self] result in
                    provider.rx.request(.getSession(idToken: result.token, uid: uid))
                            .debug()
                            .filterSuccessfulStatusAndRedirectCodes()
                            .map(UserDTO.self, using: decoder)
                }
                .asSingle()
    }

    func getUser(userId: String?) -> Single<UserDTO> {
        provider.rx.request(.getUser(userId: userId))
                .debug()
                .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
                .observeOn(SerialDispatchQueueScheduler(qos: .default))
                .filterSuccessfulStatusAndRedirectCodes()
                .map(UserDTO.self, using: decoder)
    }

    func isRegistered(uid: String?) -> Single<Bool> {
        provider.rx.request(.isRegistered(uid: uid))
                .debug()
                .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
                .observeOn(SerialDispatchQueueScheduler(qos: .default))
                .filterSuccessfulStatusAndRedirectCodes()
                .map(UserDTO.self, using: decoder)
                .map({ user in user.exists ?? false })
    }

    func listRecommendedUsers(uid: String?, userId: String?) -> Single<[UserDTO]> {
        provider.rx.request(.listRecommendedUsers(uid: uid, userId: userId))
                .debug()
                .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
                .observeOn(SerialDispatchQueueScheduler(qos: .default))
                .filterSuccessfulStatusAndRedirectCodes()
                .map([UserDTO].self, using: decoder)
    }

    func listCloseUsers(uid: String?, userId: String?) -> Single<[UserDTO]> {
        provider.rx.request(.listCloseUsers(uid: uid, userId: userId))
                .debug()
                .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
                .observeOn(SerialDispatchQueueScheduler(qos: .default))
                .filterSuccessfulStatusAndRedirectCodes()
                .map([UserDTO].self, using: decoder)
    }

    func listRealTimeAccessUsers(uid: String?, userId: String?) -> Single<[UserDTO]> {
        provider.rx.request(.listRealTimeAccessUsers(uid: uid, userId: userId))
                .debug()
                .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
                .observeOn(SerialDispatchQueueScheduler(qos: .default))
                .filterSuccessfulStatusAndRedirectCodes()
                .map([UserDTO].self, using: decoder)
    }

    func listAllUserPosts(uid: String?, userId: String?) -> Single<[PostDTO]> {
        provider.rx.request(.listAllUserPosts(uid: uid, userId: userId))
                .debug()
                .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
                .observeOn(SerialDispatchQueueScheduler(qos: .default))
                .filterSuccessfulStatusAndRedirectCodes()
                .map([PostDTO].self, using: decoder)
    }

    func listUsersRatedMeHigh(uid: String?, userId: String?) -> Single<[UserDTO]> {
        provider.rx.request(.listUsersRatedMeHigh(uid: uid, userId: userId))
                .debug()
                .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
                .observeOn(SerialDispatchQueueScheduler(qos: .default))
                .filterSuccessfulStatusAndRedirectCodes()
                .map([UserDTO].self, using: decoder)
    }

    func listUsersIRatedHigh(uid: String?, userId: String?) -> Single<[UserDTO]> {
        provider.rx.request(.listUsersIRatedHigh(uid: uid, userId: userId))
                .debug()
                .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
                .observeOn(SerialDispatchQueueScheduler(qos: .default))
                .filterSuccessfulStatusAndRedirectCodes()
                .map([UserDTO].self, using: decoder)
    }

    func listUsersRatedMe(uid: String?, userId: String?) -> Single<[RaterDTO]> {
        provider.rx.request(.listUsersRatedMe(uid: uid, userId: userId))
                .debug()
                .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
                .observeOn(SerialDispatchQueueScheduler(qos: .default))
                .filterSuccessfulStatusAndRedirectCodes()
                .map([RaterDTO].self, using: decoder)
    }

    func getPushSetting(uid: String?, userId: String?) -> Single<PushSetting> {
        provider.rx.request(.getPushSetting(uid: uid, userId: userId))
                .debug()
                .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
                .observeOn(SerialDispatchQueueScheduler(qos: .default))
                .filterSuccessfulStatusAndRedirectCodes()
                .map(PushSetting.self, using: decoder)
    }

    // POST
    func createUser(currentUser: User,
                    uid: String?,
                    phone: String?,
                    smsCode: String?,
                    smsToken: String?) -> Single<UserDTO> {
        currentUser.rx.getIDTokenResult()
                .debug()
                .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
                .observeOn(SerialDispatchQueueScheduler(qos: .default))
                .flatMap { [unowned self] result in
                    provider.rx.request(.createUser(
                                    idToken: result.token,
                                    uid: uid,
                                    phone: phone,
                                    smsCode: smsCode,
                                    smsToken: smsToken))
                            .debug()
                            .filterSuccessfulStatusAndRedirectCodes()
                            .map(UserDTO.self, using: decoder)
                            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
                }
                .asSingle()
    }

    func signInWithKakaoToken(idToken: String?) -> Single<CustomTokenDTO> {
        provider.rx.request(.signInWithKakaoToken(idToken: idToken))
                .debug()
                .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
                .observeOn(SerialDispatchQueueScheduler(qos: .default))
                .filterSuccessfulStatusAndRedirectCodes()
                .map(CustomTokenDTO.self, using: decoder)
    }

    func pushPoke(uid: String?, userId: String?) -> Single<Void> {
        provider.rx.request(.pushPoke(uid: uid, userId: userId))
                .debug()
                .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
                .observeOn(SerialDispatchQueueScheduler(qos: .default))
                .filterSuccessfulStatusAndRedirectCodes()
                .map({ _ in Void() })
    }

    func pushLookUp(uid: String?, userId: String?) -> Single<Void> {
        provider.rx.request(.pushLookUp(uid: uid, userId: userId))
                .debug()
                .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
                .observeOn(SerialDispatchQueueScheduler(qos: .default))
                .filterSuccessfulStatusAndRedirectCodes()
                .map({ _ in Void() })
    }

    func uploadUserImage(uid: String?, userId: String?, index: Int?, file: UIImage) -> Single<ImageDTO> {
        provider.rx.request(.uploadUserImage(uid: uid, userId: userId, index: index, file: file))
                .debug()
                .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
                .observeOn(SerialDispatchQueueScheduler(qos: .default))
                .filterSuccessfulStatusAndRedirectCodes()
                .map(ImageDTO.self, using: decoder)
    }

    // PUT
    func updateDeviceToken(uid: String?, deviceToken: String?) -> Single<UserDTO> {
        provider.rx.request(.updateDeviceToken(uid: uid, deviceToken: deviceToken))
                .debug()
                .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
                .observeOn(SerialDispatchQueueScheduler(qos: .default))
                .filterSuccessfulStatusAndRedirectCodes()
                .map(UserDTO.self, using: decoder)
    }

    func updateUserStatusPending(uid: String?, userId: String?) -> Single<UserDTO> {
        provider.rx.request(.updateUserStatusPending(uid: uid, userId: userId))
                .debug()
                .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
                .observeOn(SerialDispatchQueueScheduler(qos: .default))
                .filterSuccessfulStatusAndRedirectCodes()
                .map(UserDTO.self, using: decoder)
    }

    func updateUserLocation(uid: String?,
                            userId: String?,
                            latitude: Double,
                            longitude: Double,
                            area: String) -> Single<Location> {
        provider.rx.request(
                        .updateUserLocation(
                                uid: uid,
                                userId: userId,
                                latitude: latitude,
                                longitude: longitude,
                                area: area
                        )
                )
                .debug()
                .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
                .observeOn(SerialDispatchQueueScheduler(qos: .default))
                .filterSuccessfulStatusAndRedirectCodes()
                .map(Location.self, using: decoder)
    }

    func updateUserStarRatingScore(uid: String?, userId: String?, score: Int) -> Single<UserDTO> {
        provider.rx.request(.updateUserStarRatingScore(uid: uid, userId: userId, score: score))
                .debug()
                .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
                .observeOn(SerialDispatchQueueScheduler(qos: .default))
                .filterSuccessfulStatusAndRedirectCodes()
                .map(UserDTO.self, using: decoder, failsOnEmptyData: false)
    }

    func updateUserProfile(currentUser: User, uid: String?, userId: String?, user: UserDTO) -> Single<UserDTO> {
        currentUser.rx.getIDTokenResult()
                .debug()
                .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
                .observeOn(SerialDispatchQueueScheduler(qos: .default))
                .flatMap { [unowned self] result in
                    provider.rx.request(.updateUserProfile(
                                    idToken: result.token,
                                    uid: uid,
                                    userId: user.id,
                                    userDTO: user))
                            .debug()
                            .filterSuccessfulStatusAndRedirectCodes()
                            .map({ _ in user })
                            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
                }
                .asSingle()
    }

    func updateUserLastLoginAt(uid: String?, userId: String?) -> Single<Void> {
        provider.rx.request(.updateUserLastLoginAt(uid: uid, userId: userId))
                .debug()
                .filterSuccessfulStatusAndRedirectCodes()
                .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
                .observeOn(SerialDispatchQueueScheduler(qos: .default))
                .map({ _ in Void() })
    }

    func updateUserContacts(currentUser: User, uid: String?, userId: String?, phones: [String]) -> Single<Void> {
        currentUser.rx.getIDTokenResult()
                .debug()
                .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
                .observeOn(SerialDispatchQueueScheduler(qos: .default))
                .flatMap({ [unowned self] result in
                    provider.rx
                            .request(.updateUserContacts(
                                    idToken: result.token,
                                    uid: uid,
                                    userId: userId,
                                    phones: phones)
                            )
                            .debug()
                            .filterSuccessfulStatusAndRedirectCodes()
                            .map({ _ in Void() })
                            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
                })
                .asSingle()
    }

    func updateUserPushSetting(uid: String?, userId: String?, pushSetting: PushSetting) -> Single<Void> {
        provider.rx.request(.updateUserPushSetting(uid: uid, userId: userId, pushSetting: pushSetting))
                .debug()
                .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
                .observeOn(SerialDispatchQueueScheduler(qos: .default))
                .map({ _ in Void() })
    }

    // DELETE
    func deleteUserImage(uid: String?, userId: String?, index: Int) -> Single<UserDTO> {
        provider.rx.request(.deleteUserImage(uid: uid, userId: userId, index: index))
                .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
                .observeOn(SerialDispatchQueueScheduler(qos: .default))
                .debug()
                .filterSuccessfulStatusAndRedirectCodes()
                .map(UserDTO.self, using: decoder)
    }
}
