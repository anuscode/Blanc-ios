import Foundation
import RxSwift

public class FcmTokenManager {

    private let disposeBag: DisposeBag = DisposeBag()

    private let preference = Preferences()

    private let session: Session

    private let userService: UserService

    init(session: Session, userService: UserService) {
        self.session = session
        self.userService = userService
    }

    func storeToken(_ fcmToken: String) {
        preference.setDeviceToken(token: fcmToken)
        updateDeviceToken(deviceToken: fcmToken)
    }

    func retrieveToken() -> String? {
        preference.getDeviceToken()
    }

    private func updateDeviceToken(deviceToken: String?) {
        if (session.uid == nil) {
            return
        }

        userService
            .updateDeviceToken(uid: session.uid, deviceToken: deviceToken)
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
            .observeOn(SerialDispatchQueueScheduler(qos: .default))
            .subscribe(onSuccess: { _ in
                log.info("Successfully updated device token..")
            }, onError: { err in
                log.error(err)
            })
            .disposed(by: disposeBag)
    }
}