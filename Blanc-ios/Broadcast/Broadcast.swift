import Foundation
import RxSwift

class Broadcast {

    static private let disposeBag: DisposeBag = DisposeBag()

    static private let observable: PublishSubject = PublishSubject<PushDTO>()

    static func publish(_ pushDTO: PushDTO) {
        observable.onNext(pushDTO)
    }

    static func observe() -> Observable<PushDTO> {
        observable
    }
}
