import Foundation
import RxSwift

class MyRatedScoreViewModel {

    private let disposeBag: DisposeBag = DisposeBag()

    private let observable: ReplaySubject = ReplaySubject<MyRatedData>.create(bufferSize: 1)

    private var data: MyRatedData?

    private var myRatedScoreModel: MyRatedScoreModel

    init(myRatedScoreModel: MyRatedScoreModel) {
        self.myRatedScoreModel = myRatedScoreModel
        subscribeMyRatedScoreModel()
    }

    private func publish() {
        if (data == nil) {
            return
        }
        observable.onNext(data!)
    }

    func observe() -> Observable<MyRatedData> {
        observable
    }

    private func subscribeMyRatedScoreModel() {
        myRatedScoreModel.observe()
                .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
                .observeOn(SerialDispatchQueueScheduler(qos: .default))
                .subscribe(onNext: { [self] data in
                    self.data = data
                    publish()
                }, onError: { err in
                    log.error(err)
                })
                .disposed(by: disposeBag)
    }
}
