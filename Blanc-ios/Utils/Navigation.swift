import CoreLocation
import Foundation
import FirebaseAuth
import RxSwift
import UserNotifications
import UIKit

enum Next {
    case LOCATION,
         LOGIN,
         MAIN,
         REGISTRATION,
         SMS
}

class Navigation {

    private var auth: Auth = Auth.auth()

    private var disposeBag: DisposeBag = DisposeBag()

    private let center = UNUserNotificationCenter.current()

    private let manager = CLLocationManager()

    internal var userService: UserService

    internal var session: Session

    init(session: Session, userService: UserService) {
        self.session = session
        self.userService = userService
    }

    public func next() -> Single<Next> {
        if (!isLocationAuthorized()) {
            let subject: ReplaySubject<Next> = ReplaySubject.create(bufferSize: 1)
            subject.onNext(.LOCATION)
            return subject.take(1).asSingle()
        }
        return route1()
    }

    private func route1() -> Single<Next> {
        guard let uid = auth.uid else {
            let subject: ReplaySubject<Next> = ReplaySubject.create(bufferSize: 1)
            subject.onNext(.LOGIN)
            return subject.take(1).asSingle()
        }
        return userService
            .isRegistered(uid: uid)
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
            .observeOn(SerialDispatchQueueScheduler(qos: .default))
            .flatMap({ [unowned self] isRegistered -> Single<Next> in
                switch isRegistered {
                case true:
                    return route2()
                case false:
                    let subject: ReplaySubject<Next> = ReplaySubject.create(bufferSize: 1)
                    subject.onNext(.SMS)
                    return subject.take(1).asSingle()
                }
            })
            .catchErrorJustReturn(.LOGIN)
    }

    private func route2() -> Single<Next> {
        session
            .generate()
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
            .observeOn(SerialDispatchQueueScheduler(qos: .default))
            .flatMap({ [unowned self] _ in
                let subject: ReplaySubject<Next> = ReplaySubject.create(bufferSize: 1)
                let available = session.user?.available
                switch available {
                case true:
                    subject.onNext(Next.MAIN)
                default:
                    subject.onNext(Next.REGISTRATION)
                }
                return subject.take(1).asSingle()
            })
            .catchErrorJustReturn(.LOGIN)
    }

    private func isLocationAuthorized() -> Bool {
        log.info(manager.authorizationStatus)
        return manager.authorizationStatus.rawValue > 2
    }
}
