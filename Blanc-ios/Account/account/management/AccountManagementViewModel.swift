import Foundation
import RxSwift
import RxDataSources
import FirebaseAuth

class AccountManagementViewModel {

    private let disposeBag: DisposeBag = DisposeBag()

    private let auth: Auth = Auth.auth()

    internal let sections: ReplaySubject = ReplaySubject<[SectionModel<String, String>]>.create(bufferSize: 1)

    internal let toast: PublishSubject = PublishSubject<String>()

    internal let replaceViewController: PublishSubject = PublishSubject<Void>()

    private let session: Session

    private let userService: UserService

    init(session: Session, userService: UserService) {
        self.session = session
        self.userService = userService
        populate()
    }

    private func populate() {
        let sections = [
            SectionModel<String, String>(model: "로그 아웃", items: ["로그 아웃"]),
            SectionModel<String, String>(model: "회원 탈퇴", items: ["회원 탈퇴"])
        ]
        self.sections.onNext(sections)
    }

    internal func logout() {
        do {
            try auth.signOut()
            replaceViewController.onNext(Void())
        } catch {
            toast.onNext("로그아웃에 실패 하였습니다. 다시 시도해 주세요.")
        }
    }

    func withdraw() {
        guard let currentUser = auth.currentUser,
              let uid = session.uid,
              let userId = session.id else {
            return
        }
        userService
            .withdraw(currentUser: currentUser, uid: uid, userId: userId)
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
            .observeOn(MainScheduler.instance)
            .subscribe(onSuccess: { [unowned self] _ in
                session.signOut()
                replaceViewController.onNext(Void())
            }, onError: { [unowned self] err in
                log.error(err)
                toast.onNext("회원탈퇴 도중 에러가 발생 하였습니다.")
            })
            .disposed(by: disposeBag)
    }
}
