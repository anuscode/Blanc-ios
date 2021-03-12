import Foundation
import RxSwift
import RxDataSources

class AccountViewModel {

    private let disposeBag: DisposeBag = DisposeBag()

    let sections: ReplaySubject<[SectionModel<String, AccountData>]> =
        ReplaySubject<[SectionModel<String, AccountData>]>.create(bufferSize: 1)

    let currentUser: ReplaySubject = ReplaySubject<UserDTO>.create(bufferSize: 1)

    private weak var session: Session?

    init(session: Session) {
        self.session = session
        populate()
    }

    private func populate() {
        session?
            .observe()
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
            .observeOn(SerialDispatchQueueScheduler(qos: .default))
            .subscribe(onNext: { [unowned self] user in
                currentUser.onNext(user)
            }, onError: { err in
                log.error(err)
            })
            .disposed(by: disposeBag)

        sections.onNext([
            SectionModel<String, AccountData>(model: "결제", items: [
                AccountData(icon: "dollarsign.circle", title: "결제 하기")
            ]),
            SectionModel<String, AccountData>(model: "설정", items: [
                AccountData(icon: "bell", title: "푸시 설정"),
                AccountData(icon: "gearshape", title: "계정 관리")
            ]),
            SectionModel<String, AccountData>(model: "고객 센터", items: [
                AccountData(icon: "atom", title: "고객 센터"),
                AccountData(icon: "lightbulb", title: "블랑를 개선 시킬 의견을 주세요!")
            ])
        ])
    }
}
