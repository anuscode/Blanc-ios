import Foundation
import RxSwift


class Background {

    static private let observable: PublishSubject = PublishSubject<Void>()

    static func publish() {
        log.info("Found notification while background..")
        observable.onNext(Void())
    }

    static func observe() -> Observable<Void> {
        observable
    }
}
