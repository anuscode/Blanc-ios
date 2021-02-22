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
                .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
                .flatMap { [self] result in
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
                .filterSuccessfulStatusAndRedirectCodes()
                .map(UserDTO.self, using: decoder)
                .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
    }

    func isRegistered(uid: String?) -> Single<Bool> {
        provider.rx.request(.isRegistered(uid: uid))
                .debug()
                .filterSuccessfulStatusAndRedirectCodes()
                .map(UserDTO.self, using: decoder)
                .map({ user in user.exists ?? false })
                .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
    }

    func listRecommendedUsers(uid: String?, userId: String?) -> Single<[UserDTO]> {
        provider.rx.request(.listRecommendedUsers(uid: uid, userId: userId))
                .debug()
                .filterSuccessfulStatusAndRedirectCodes()
                .map([UserDTO].self, using: decoder)
                .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
    }

    func listCloseUsers(uid: String?, userId: String?) -> Single<[UserDTO]> {
        provider.rx.request(.listCloseUsers(uid: uid, userId: userId))
                .debug()
                .filterSuccessfulStatusAndRedirectCodes()
                .map([UserDTO].self, using: decoder)
                .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
    }

    func listRealTimeAccessUsers(uid: String?, userId: String?) -> Single<[UserDTO]> {
        provider.rx.request(.listRealTimeAccessUsers(uid: uid, userId: userId))
                .debug()
                .filterSuccessfulStatusAndRedirectCodes()
                .map([UserDTO].self, using: decoder)
                .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
    }

    func listAllUserPosts(uid: String?, userId: String?) -> Single<[PostDTO]> {
        provider.rx.request(.listAllUserPosts(uid: uid, userId: userId))
                .debug()
                .filterSuccessfulStatusAndRedirectCodes()
                .map([PostDTO].self, using: decoder)
                .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
    }

    func listUsersRatedMeHigh(uid: String?, userId: String?) -> Single<[UserDTO]> {
        provider.rx.request(.listUsersRatedMeHigh(uid: uid, userId: userId))
                .debug()
                .filterSuccessfulStatusAndRedirectCodes()
                .map([UserDTO].self, using: decoder)
                .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
    }

    func listUsersIRatedHigh(uid: String?, userId: String?) -> Single<[UserDTO]> {
        provider.rx.request(.listUsersIRatedHigh(uid: uid, userId: userId))
                .debug()
                .filterSuccessfulStatusAndRedirectCodes()
                .map([UserDTO].self, using: decoder)
                .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
    }

    func listUsersRatedMe(uid: String?, userId: String?) -> Single<[RaterDTO]> {
        provider.rx.request(.listUsersRatedMe(uid: uid, userId: userId))
                .debug()
                .filterSuccessfulStatusAndRedirectCodes()
                .map([RaterDTO].self, using: decoder)
                .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
    }

    // POST
    func createUser(currentUser: User,
                    uid: String?,
                    phone: String?,
                    smsCode: String?,
                    smsToken: String?) -> Single<UserDTO> {
        currentUser.rx.getIDTokenResult()
                .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
                .flatMap { [self] result in
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
                .filterSuccessfulStatusAndRedirectCodes()
                .map(CustomTokenDTO.self, using: decoder)
                .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
    }

    func pushPoke(uid: String?, userId: String?) -> Single<Void> {
        provider.rx.request(.pushPoke(uid: uid, userId: userId))
                .debug()
                .filterSuccessfulStatusAndRedirectCodes()
                .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
                .map({ _ in Void() })
    }

    func pushLookUp(uid: String?, userId: String?) -> Single<Void> {
        provider.rx.request(.pushLookUp(uid: uid, userId: userId))
                .debug()
                .filterSuccessfulStatusAndRedirectCodes()
                .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
                .map({ _ in Void() })
    }

    func uploadUserImage(uid: String?, userId: String?, index: Int?, file: UIImage) -> Single<ImageDTO> {
        provider.rx.request(.uploadUserImage(uid: uid, userId: userId, index: index, file: file))
                .debug()
                .filterSuccessfulStatusAndRedirectCodes()
                .map(ImageDTO.self, using: decoder)
                .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
    }

    // PUT
    func updateDeviceToken(uid: String?, deviceToken: String?) -> Single<UserDTO> {
        provider.rx.request(.updateDeviceToken(uid: uid, deviceToken: deviceToken))
                .debug()
                .filterSuccessfulStatusAndRedirectCodes()
                .map(UserDTO.self, using: decoder)
                .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
    }

    func updateUserStatusPending(uid: String?, userId: String?) -> Single<UserDTO> {
        provider.rx.request(.updateUserStatusPending(uid: uid, userId: userId))
                .debug()
                .filterSuccessfulStatusAndRedirectCodes()
                .map(UserDTO.self, using: decoder)
                .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
    }

    func updateUserLocation(uid: String?, userId: String?,
                            latitude: Double?, longitude: Double?, area: String?) -> Single<Location> {
        provider.rx.request(.updateUserLocation(
                        uid: uid, userId: userId,
                        latitude: latitude, longitude: longitude,
                        area: area))
                .debug()
                .filterSuccessfulStatusAndRedirectCodes()
                .map(Location.self, using: decoder)
                .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
    }

    func updateUserStarRatingScore(uid: String?, userId: String?, score: Int) -> Single<UserDTO> {
        provider.rx.request(.updateUserStarRatingScore(uid: uid, userId: userId, score: score))
                .debug()
                .filterSuccessfulStatusAndRedirectCodes()
                .map(UserDTO.self, using: decoder, failsOnEmptyData: false)
                .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
    }

    func updateUserProfile(currentUser: User, uid: String?, userId: String?, user: UserDTO) -> Single<UserDTO> {
        currentUser.rx.getIDTokenResult()
                .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
                .flatMap { [self] result in
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
                .map({ _ in Void() })
    }

    func updateUserContacts(currentUser: User, uid: String?, userId: String?, phones: [String]) -> Single<Void> {
        currentUser.rx.getIDTokenResult()
                .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
                .flatMap { [self] result in
                    provider.rx.request(
                                    .updateUserContacts(
                                            idToken: result.token,
                                            uid: uid,
                                            userId: userId,
                                            phones: phones))
                            .debug()
                            .filterSuccessfulStatusAndRedirectCodes()
                            .map({ _ in Void() })
                            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
                }
                .asSingle()
    }

    // DELETE
    func deleteUserImage(uid: String?, userId: String?, index: Int) -> Single<UserDTO> {
        provider.rx.request(.deleteUserImage(uid: uid, userId: userId, index: index))
                .debug()
                .filterSuccessfulStatusAndRedirectCodes()
                .map(UserDTO.self, using: decoder)
                .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
    }
}
