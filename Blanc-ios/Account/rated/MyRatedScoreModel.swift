import Foundation
import RxSwift
import FirebaseAuth

class MyRatedData {
    var currentUser: UserDTO?
    var raters: [RaterDTO]?
}

class MyRatedScoreModel {

    private let disposeBag: DisposeBag = DisposeBag()

    private let observable: ReplaySubject = ReplaySubject<MyRatedData>.create(bufferSize: 1)

    private let auth: Auth = Auth.auth()

    private var data: MyRatedData = MyRatedData()

    var session: Session

    private var userService: UserService

    init(session: Session, userService: UserService) {
        self.session = session
        self.userService = userService
        populate()
    }

    func publish() {
        observable.onNext(data)
    }

    func observe() -> Observable<MyRatedData> {
        observable
    }

    func populate() {
        userService.listUsersRatedMe(uid: session.uid, userId: session.id)
                .observeOn(SerialDispatchQueueScheduler(qos: .default))
                .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
                .subscribe(onSuccess: { [unowned self] raters in
                    data.raters = raters
                    data.currentUser = session.user
                    publish()
                }, onError: { err in
                    log.error(err)
                })
                .disposed(by: disposeBag)
    }
}
