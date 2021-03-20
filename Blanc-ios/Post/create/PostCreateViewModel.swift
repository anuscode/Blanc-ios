import Foundation
import UIKit
import RxSwift

class PostCreateViewModel {

    private let disposeBag: DisposeBag = DisposeBag()

    internal let toast: PublishSubject = PublishSubject<String>()

    internal let loading: PublishSubject = PublishSubject<Bool>()

    internal let popView: PublishSubject = PublishSubject<Void>()

    internal let createButton: PublishSubject = PublishSubject<Bool>()

    private var postCreateModel: PostCreateModel

    init(postCreateModel: PostCreateModel) {
        self.postCreateModel = postCreateModel
    }

    func createPost(files: [UIImage], description: String?, enableComment: Bool) {
        loading.onNext(true)
        createButton.onNext(false)
        postCreateModel
            .createPost(
                files: files,
                description: description,
                enableComment: enableComment
            )
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
            .observeOn(SerialDispatchQueueScheduler(qos: .default))
            .do(onDispose: { [unowned self] in
                loading.onNext(false)
                createButton.onNext(true)
            })
            .subscribe(onSuccess: { [unowned self] in
                toast.onNext("게시물이 등록 되었습니다.")
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [unowned self] in
                    popView.onNext(Void())
                }
            }, onError: { [unowned self] err in
                toast.onNext("핑스타그램 게시물 등록에 실패 하였습니다.")
            })
            .disposed(by: disposeBag)
    }
}
