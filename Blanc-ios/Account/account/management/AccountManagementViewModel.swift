import Foundation
import RxSwift
import RxDataSources
import FirebaseAuth

class AccountManagementViewModel {

    private let auth: Auth = Auth.auth()

    internal let sections: ReplaySubject = ReplaySubject<[SectionModel<String, String>]>.create(bufferSize: 1)

    internal let toast: PublishSubject = PublishSubject<String>()

    internal let screenOut: PublishSubject = PublishSubject<Void>()

    init() {
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
            screenOut.onNext(Void())
        } catch {
            toast.onNext("로그아웃에 실패 하였습니다. 다시 시도해 주세요.")
        }
    }

    internal func unregister() {
        print("unregister..")
    }
}
